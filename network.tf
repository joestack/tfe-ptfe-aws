terraform {
  required_version = ">= 0.11.0"
}

provider "aws" {
}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
data "aws_ami" "nat_instance" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # Amazon
}


# VPC 

resource "aws_vpc" "hc_tfe_vpc" {
  cidr_block           = "${var.network_address_space}"
  enable_dns_hostnames = "true"

  tags {
          Name        = "${var.name}-vpc"
          Environment = "${var.environment_tag}"
          TTL         = "${var.ttl}"
          Owner       = "${var.owner}"
  }

}

# Internet Gateways and route table

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.hc_tfe_vpc.id}"
  
  tags {
          Name        = "${var.name}-igw"
          Environment = "${var.environment_tag}"
          TTL         = "${var.ttl}"
          Owner       = "${var.owner}"
  }

}

resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.hc_tfe_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

    tags {
        Name        = "${var.name}-rtb"
        Environment = "${var.environment_tag}"
        TTL         = "${var.ttl}"
        Owner       = "${var.owner}"
    }

}

# nat route table

resource "aws_route_table" "rtb-nat" {
    vpc_id = "${aws_vpc.hc_tfe_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }

    tags {
        Name = "${var.name}-rtb-nat"
        Environment = "${var.environment_tag}"
        TTL         = "${var.ttl}"
        Owner       = "${var.owner}"
    }
}

# public subnet to IGW

resource "aws_route_table_association" "dmz-subnet" {
  subnet_id      = "${aws_subnet.dmz_subnet.*.id[0]}"
  route_table_id = "${aws_route_table.rtb.id}"
    
}

# limit the amout of public web subnets to the amount of AZ or less
resource "aws_route_table_association" "pub_tfe-subnet" {
  count          = "${local.mod_az}"
  subnet_id      = "${element(aws_subnet.pub_tfe_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rtb.id}"
    
}

# private subnet to NAT


resource "aws_route_table_association" "rtb-tfe" {
    count          = "${var.tfe_subnet_count}"
    subnet_id      = "${element(aws_subnet.tfe_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.rtb-nat.id}"

}


# subnet public

resource "aws_subnet" "dmz_subnet" {
  vpc_id                  = "${aws_vpc.hc_tfe_vpc.id}"
  cidr_block              = "${cidrsubnet(var.network_address_space, 8, 1)}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

      tags {
        Name = "${var.name}-dmz-sn"
        Environment = "${var.environment_tag}"
        TTL         = "${var.ttl}"
        Owner       = "${var.owner}"     
  }

}


resource "aws_subnet" "pub_tfe_subnet" {
  #count                   = "${local.mod_az}"
  count                   = "1"
  cidr_block              = "${cidrsubnet(var.network_address_space, 8, count.index + 10)}"
  vpc_id                  = "${aws_vpc.hc_tfe_vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index % local.mod_az]}"

      tags {
        Name = "${var.name}-tfe-pub-sn"
        Environment = "${var.environment_tag}"
        TTL         = "${var.ttl}"
        Owner       = "${var.owner}"     
  }

}

# subnet private


resource "aws_subnet" "tfe_subnet" {
  count                   = "${var.tfe_subnet_count}"
  cidr_block              = "${cidrsubnet(var.network_address_space, 8, count.index + 20)}"
  vpc_id                  = "${aws_vpc.hc_tfe_vpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index % local.mod_az]}"


      tags {
        Name = "${var.name}-tfe-sn"
        Environment = "${var.environment_tag}"
        TTL         = "${var.ttl}"
        Owner       = "${var.owner}"     
  }

}


resource "aws_instance" "nat" {
  ami                         = "${data.aws_ami.nat_instance.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.dmz_subnet.id}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
  key_name                    = "${var.key_name}"
  source_dest_check           = false


      tags {
        Name = "${var.name}-nat-sn"
        Environment = "${var.environment_tag}"
        TTL         = "${var.ttl}"
        Owner       = "${var.owner}"     
  }

}
