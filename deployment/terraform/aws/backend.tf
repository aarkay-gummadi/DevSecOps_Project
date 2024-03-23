terraform {
  backend "s3" {
    bucket = "southbucketforaarkay"
    key    = "eks/terraform.tfstate"
    region = "us-west-2"
  }
}