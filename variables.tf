variable "owner" {}
variable "name" {}
variable "ttl" {}
variable "environment_tag" {}
 
variable "key_name" {}

variable "id_rsa_aws" {}

variable "dns_domain" {
    default = "joestack.xyz"
}

variable "network_address_space" {
    default = "192.168.0.0/16"
}

variable "ssh_user" {
    default = "ubuntu"
}


locals {
    mod_az = "1"
}


variable "tfe_subnet_count" {
    default = "1"
}

variable "tfe_node_count" {
  default = "1"
}


variable "instance_type" {
  default = "t2.medium"
}





