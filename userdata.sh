#!/bin/bash
set -euxo pipefail

# Log all output
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "========== Starting Jenkins Bastion Server Setup =========="

# Update OS
dnf update -y

# -------------------------------------------------
# Install Java 21
# -------------------------------------------------
dnf install -y java-21-amazon-corretto

# -------------------------------------------------
# Install Git
# -------------------------------------------------
dnf install -y git

# -------------------------------------------------
# Install Maven
# -------------------------------------------------
dnf install -y maven

# -------------------------------------------------
# Install Jenkins
# -------------------------------------------------
wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

dnf install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# -------------------------------------------------
# Install Docker
# -------------------------------------------------
dnf install -y docker

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user
usermod -aG docker jenkins

# -------------------------------------------------
# Install AWS CLI v2
# -------------------------------------------------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o "awscliv2.zip"

dnf install -y unzip

unzip awscliv2.zip

./aws/install

# -------------------------------------------------
# Install Terraform
# -------------------------------------------------
dnf install -y yum-utils

yum-config-manager --add-repo \
https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

dnf install -y terraform

# -------------------------------------------------
# Install kubectl
# -------------------------------------------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# -------------------------------------------------
# Install eksctl
# -------------------------------------------------
curl --silent --location \
"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" \
| tar xz -C /tmp

mv /tmp/eksctl /usr/local/bin

# -------------------------------------------------
# Install Helm
# -------------------------------------------------
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# -------------------------------------------------
# Install Trivy
# -------------------------------------------------
rpm --import https://aquasecurity.github.io/trivy-repo/rpm/public.key

cat <<EOF > /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy Repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF

dnf install -y trivy

# -------------------------------------------------
# Pull SonarQube Image
# -------------------------------------------------
docker pull sonarqube:lts-community

docker run -d \
--name sonarqube \
--restart always \
-p 9000:9000 \
sonarqube:lts-community

# -------------------------------------------------
# Show Versions
# -------------------------------------------------
java -version
jenkins --version || true
docker --version
aws --version
terraform --version
kubectl version --client
eksctl version
helm version
trivy --version

echo "========== Installation Completed =========="