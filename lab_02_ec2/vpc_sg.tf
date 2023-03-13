
## Data sources to identify the default vpc and its subnets
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
data "aws_vpc" "def_vpc" {
  default = true
}

# Subnet data source
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet
data "aws_subnets" "def_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.def_vpc.id]
  }
}

resource "aws_security_group" "sec_web" {
  vpc_id = data.aws_vpc.def_vpc.id
  name   = "sec-web-${var.project}"
  ingress {
    description = "Temp for testing - SSH from specific addresses"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sec_allowed_external
  }
  ingress {
    description = "Ping from specific addresses"
    from_port   = 8 # ICMP Code 8 - echo  (0 is echo reply)
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = var.sec_allowed_external
    # security_groups = [aws_security_group.sec_alb.id]
  }

  ingress {
    description = "TCP Port 5000 from specific addresses"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.sec_allowed_external
    # security_groups = [aws_security_group.sec_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sec-web"
  }
  lifecycle {
    create_before_destroy = true
  }
}
