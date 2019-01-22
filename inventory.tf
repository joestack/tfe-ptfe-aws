## dynamically generate a `inventory` file for Ansible Configuration Automation 

data "template_file" "ansible_tfe_hosts" {
    count      = "${var.tfe_node_count}"
    template   = "${file("${path.module}/templates/ansible_hosts.tpl")}"
    depends_on = ["aws_instance.tfe_nodes"]

      vars {
        node_name    = "${lookup(aws_instance.tfe_nodes.*.tags[count.index], "Name")}"
        ansible_user = "${var.ssh_user}"
        extra        = "ansible_host=${element(aws_instance.tfe_nodes.*.private_ip,count.index)}"
      }

}


data "template_file" "ansible_groups" {
    template = "${file("${path.module}/templates/ansible_groups.tpl")}"

      vars {
        jump_host_ip  = "${aws_instance.jumphost.public_ip}"
        ssh_user_name = "${var.ssh_user}"
        tfe_hosts_def = "${join("",data.template_file.ansible_tfe_hosts.*.rendered)}"
      }

}

resource "local_file" "ansible_inventory" {
    
    depends_on = ["data.template_file.ansible_groups"]
    
    content = "${data.template_file.ansible_groups.rendered}"
    filename = "${path.module}/inventory"

}


resource "null_resource" "provisioner" {

depends_on = ["local_file.ansible_inventory"]
   
    triggers {    
        always_run = "${timestamp()}"
  }

  provisioner "file" {
    source      = "${path.module}/inventory"
    destination = "~/inventory"
  
    connection {
      type     = "ssh"
      host     = "${aws_instance.jumphost.public_ip}"
      user     = "${var.ssh_user}"
      private_key = "${var.id_rsa_aws}"
      insecure = true
    }
  }

}
