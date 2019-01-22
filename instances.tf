# INSTANCES #

resource "aws_instance" "tfe_nodes" {
  count                       = "${var.tfe_node_count}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${aws_subnet.tfe_subnet.id}"
  private_ip                  = "${cidrhost(aws_subnet.tfe_subnet.cidr_block, count.index + 100)}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = ["${aws_security_group.tfe.id}"]
  key_name                    = "${var.key_name}"
  
  tags = [
  {
         Name = "${format("ptfe-%02d.${var.dns_domain}", count.index + 1)}"
  },
  {
         key = "owner"
         value = "${var.owner}"
         propagate_at_launch = true
  },
  {
         key = "TTL"
         value = "-1"
         propagate_at_launch = true
  }

  ]

  ebs_block_device {
      device_name = "/dev/xvdb"
      volume_type = "gp2"
      volume_size = 40
    }

  ebs_block_device {
      device_name = "/dev/xvdc"
      volume_type = "gp2"
      volume_size = 20
    }

  user_data = "${file("./templates/userdata.sh")}"

}



