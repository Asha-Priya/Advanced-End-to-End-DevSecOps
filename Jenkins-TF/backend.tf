terraform {
  backend "s3" {
    bucket         = "devsecops-project-buckett"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}