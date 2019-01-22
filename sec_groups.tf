resource "aws_security_group" "jumphost" {
    name = "${var.name}-jumphost-sg"
    description = "Jumphost/Bastion servers"
    vpc_id = "${aws_vpc.hc_tfe_vpc.id}"
}

resource "aws_security_group_rule" "jh-ssh" {
    security_group_id = "${aws_security_group.jumphost.id}"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jh-egress" {
    security_group_id = "${aws_security_group.jumphost.id}"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group" "tfe" {
    name = "${var.name}-tfe-sg"
    description = "private tfe"
    vpc_id = "${aws_vpc.hc_tfe_vpc.id}"
}

resource "aws_security_group_rule" "tfe-http" {
    security_group_id = "${aws_security_group.tfe.id}"
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "tfe-https" {
    security_group_id = "${aws_security_group.tfe.id}"
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "tfe-admin" {
    security_group_id = "${aws_security_group.tfe.id}"
    type = "ingress"
    from_port = 8800
    to_port = 8800
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "tfe-egress" {
    security_group_id = "${aws_security_group.tfe.id}"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "elb" {
    name = "${var.name}-elb-sg"
    description = "elasic loadbalancer"
    vpc_id = "${aws_vpc.hc_tfe_vpc.id}"
}

resource "aws_security_group_rule" "elb-http" {
    security_group_id = "${aws_security_group.elb.id}"
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb-https" {
    security_group_id = "${aws_security_group.elb.id}"
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb-admin" {
    security_group_id = "${aws_security_group.elb.id}"
    type = "ingress"
    from_port = 8800
    to_port = 8800
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "elb-egress" {
    security_group_id = "${aws_security_group.elb.id}"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group" "nat" {
    name = "${var.name}-nat-sg"
    description = "nat instance"
    vpc_id = "${aws_vpc.hc_tfe_vpc.id}"
}

resource "aws_security_group_rule" "nat-http" {
    security_group_id = "${aws_security_group.nat.id}"
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}resource "aws_security_group_rule" "nat-htts" {
    security_group_id = "${aws_security_group.nat.id}"
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "nat-egress" {
    security_group_id = "${aws_security_group.nat.id}"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
