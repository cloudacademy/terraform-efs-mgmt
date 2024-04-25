data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_key_pair" "lab" {
  key_name = data.aws_caller_identity.current.id
}

# LOCALS
#====================================

locals {
  name        = "cloudacademydevops"
  environment = "prod"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  # returns
  #   tolist([
  #   "us-west-2a",
  #   "us-west-2b"
  # ])
}

# VPC
#====================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.0.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = false

  manage_default_network_acl    = true
  manage_default_route_table    = true
  manage_default_security_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  default_network_acl_tags = {
    Name = "${local.name}-default"
  }

  default_route_table_tags = {
    Name = "${local.name}-default"
  }

  default_security_group_tags = {
    Name = "${local.name}-default"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = length(local.azs)
  file_system_id  = module.efs.file_system_id
  subnet_id       = element(module.vpc.private_subnets, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}

# SGs
#====================================

resource "aws_security_group" "instance_sg" {
  name        = "allow_public_access"
  description = "Allow Traffic from Anywhere"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = var.public_instance_sg_ports
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "instance_sg"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "allow_from_public_instances"
  description = "Allow traffic from public instance sg only"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = var.efs_sg_ports
    content {
      from_port       = ingress.value["port"]
      to_port         = ingress.value["port"]
      protocol        = ingress.value["protocol"]
      security_groups = [aws_security_group.instance_sg.id]
    }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.instance_sg.id]
  }

  tags = {
    "Name" = "efs_sg"
  }
}

# EC2
#====================================

resource "aws_iam_instance_profile" "instance" {
  role = "ec2-labinstance-role"
}

resource "aws_instance" "instances" {
  count                       = length(local.azs)
  ami                         = "ami-035bf26fb18e75d1b"
  instance_type               = "t3.micro"
  key_name                    = data.aws_key_pair.lab.key_name
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  subnet_id                   = element(module.vpc.public_subnets, count.index)
  iam_instance_profile        = aws_iam_instance_profile.instance.name
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    "Name" = "instance_0${count.index + 1}"
  }

  depends_on = [
    aws_efs_mount_target.efs_mount_target
  ]
}
