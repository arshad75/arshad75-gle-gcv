# Create the EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.tags.Environment}-eks-cluster"
  version = var.eks_version
 role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
 endpoint_public_access = false
  }

  tags = merge(
    var.tags,
    {
 Name = "${var.tags.Environment}-eks-cluster"
    },
  )
}

# Create IAM role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "${var.tags.Environment}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach AmazonEKSClusterPolicy to the EKS Cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Create IAM role for EKS Managed Node Group
resource "aws_iam_role" "eks_node_group" {
  name = "${var.tags.Environment}-eks-node-group-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
 "Principal": {
 "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach AmazonEKSWorkerNodePolicy to the EKS Node Group role
resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

# Attach AmazonEC2ContainerRegistryReadOnly to the EKS Node Group role
resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# Create EKS Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.tags.Environment}-eks-node-group"
 node_role_arn  = aws_iam_role.eks_node_group.arn
  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_capacity
    max_size     = var.node_group_max_size
 min_size     = var.node_group_min_size
  }

  instance_types = var.node_group_instance_types

  tags = merge(
    var.tags,
    {
      Name = "${var.tags.Environment}-eks-node-group"
    },
  )
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name, "--region", var.region]
    command     = "aws"
  }
}