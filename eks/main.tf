
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

data "aws_iam_role" "cluster_roles" {
  name = var.cluster_role
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Tier = "private"
  }
}

resource "aws_eks_cluster" "eks" {
  name     = "coin98-cluster"
  role_arn = data.aws_iam_role.cluster_roles.arn

  vpc_config {
    security_group_ids      = [var.cluster_sg_id]
    endpoint_public_access  = true
    subnet_ids              = data.aws_subnets.private.ids
  }

  tags = {
    Name = "coin98-cluster"
  }
}

resource "aws_eks_addon" "addons" {
  cluster_name      = aws_eks_cluster.eks.id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.21.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
}

data "aws_iam_role" "nodegroup_roles" {
  name = var.nodegroup_role
}

resource "aws_eks_node_group" "nodegroup" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "coin98-nodegroup"
  node_role_arn   = data.aws_iam_role.nodegroup_roles.arn
  subnet_ids      = data.aws_subnets.private.ids

  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  tags = {
    Name = "coin98-nodegroup"
  }
}
