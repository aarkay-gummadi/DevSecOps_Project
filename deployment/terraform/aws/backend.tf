terraform {
  backend "s3" {
    bucket = "waytos3"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}