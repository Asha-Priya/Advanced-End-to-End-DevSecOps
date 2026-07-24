terraform {
  backend "s3" {
    bucket         = "asha-devsecops-tf-state"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}