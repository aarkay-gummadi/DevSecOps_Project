provider "aws" {
  region = "us-west-2"  # Specify your desired AWS region
}

# Create a VPC for EKS
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create subnets in different availability zones
resource "aws_subnet" "eks_subnet" {
  count = 3

  cidr_block = "10.0.${count.index + 1}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  vpc_id = aws_vpc.eks_vpc.id
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com",
      },
    }],
  })
}

# Attach AmazonEKSClusterPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Create EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "example-eks-cluster"
  subnets         = aws_subnet.eks_subnet[*].id
  vpc_id          = aws_vpc.eks_vpc.id
  cluster_version = "1.21"  # Specify the desired Kubernetes version

  node_groups = {
    eks_nodes = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      key_name = "OregonEswar"  # Specify your SSH key name

      instance_type = "t2.medium"  # Specify the desired instance type
    }
  }
}

# Output kubeconfig for local usage
output "kubeconfig" {
  value     = module.eks.kubeconfig
  sensitive = true
}
