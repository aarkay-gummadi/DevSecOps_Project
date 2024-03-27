terraform {
  backend "s3" {
    bucket = "southbucketforaarkay"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}