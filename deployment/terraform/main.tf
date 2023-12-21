terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "fordevsecops1"
    key            = "workshopdec23.tfstate"
    region         = "us-west-2"  # Specify the AWS region where your S3 bucket is located
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

resource "aws_eks_cluster" "example" {
  name     = "example-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
}

resource "aws_iam_role" "eks_cluster" {
  name = "example-eks-cluster"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_subnet" "private" {
  count = 2
  
  cidr_block = "10.0.${count.index + 1}.0/24"
}

output "kubeconfig" {
  value = aws_eks_cluster.example.kubeconfig[*].raw_config
  sensitive = true
}

resource "null_resource" "get_kube_config" {
  depends_on = [aws_eks_cluster.example]

  triggers = {
    cluster_id = aws_eks_cluster.example.id
  }

  provisioner "local-exec" {
    command = "aws eks --region us-east-1 update-kubeconfig --name ${aws_eks_cluster.example.name}"
  }
}