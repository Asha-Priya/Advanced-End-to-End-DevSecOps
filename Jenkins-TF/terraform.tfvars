aws_region   = "ap-south-1"
project_name = "jenkins-bastion"

vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
availability_zone  = "ap-south-1a"

instance_type = "c7i-flex.large"
key_name      = "Devops"

bucket_name    = "devsecops-project-buckett"
dynamodb_table = "terraform-lock"