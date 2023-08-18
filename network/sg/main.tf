
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.19.0"
   }
 }
}

provider "aws" {
  # Configuration options
  region  = "us-east-1"
  profile = "default"
}

data "aws_vpc" "coin98" {
  id = var.vpc_id
}

resource "aws_security_group" "eks_cluster" {
  name        = "cluster_security_group"
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = data.aws_vpc.coin98.id

  tags = {
    Name        = "cluster_security_group"
    Environment = "dev"
  }
}

resource "aws_security_group" "nodegroup" {
  name        = "nodegroup_security_group"
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = data.aws_vpc.coin98.id

  tags = {
    Name        = "nodegroup_security_group"
    Environment = "dev"
  }
}

resource "aws_security_group_rule" "cluster_ingress_01" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "cluster_ingress_02" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.nodegroup.id
}

resource "aws_security_group_rule" "cluster_egress_01" {
  type              = "egress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "nodegroup_ingress_01" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodegroup.id
  source_security_group_id = aws_security_group.nodegroup.id
}

resource "aws_security_group_rule" "nodegroup_ingress_02" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 10250
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodegroup.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "nodegroup_egress_01" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nodegroup.id
}

# For ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb_security_group"
  vpc_id      = data.aws_vpc.coin98.id

  tags = {
    Name        = "ALB"
    Environment = "dev"
  }
}

resource "aws_security_group_rule" "alb_rule_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_rule_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

