# -----------------------------
# IAM Role for EC2
# -----------------------------
resource "aws_iam_role" "jenkins_role" {
  name = "${var.project_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# -----------------------------
# Attach AdministratorAccess Policy
# -----------------------------
resource "aws_iam_role_policy_attachment" "jenkins_admin_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# -----------------------------
# Instance Profile
# -----------------------------
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.jenkins_role.name
}