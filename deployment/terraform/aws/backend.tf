terraform {
  backend "s3" {
    bucket = "oregonbucketfordevsecops"
    key    = "eks/terraform.tfstate"
    region = "us-west-2"
  }
}