#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-log-user-data/
yum update -y
# Install Docker
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on
# Download binaries
cd /home/ec2-user
curl -o fargatesetup.zip https://ee-assets-prod-us-east-1.s3.us-east-1.amazonaws.com/modules/2160a6f9d46f4474ae62edd1e48c1d5b/v1/fargatesetup.zip
unzip fargatesetup.zip
# Build docker image
docker build -t stp/lab1 .
# Create ECR repo
aws ecr create-repository --repository-name containers-lab1 --region us-east-2
# Environment variables
export AWS_DEFAULT_REGION=us-east-2
export ACCOUNT_NUMBER=`aws sts get-caller-identity --query 'Account' --output text`
export ECR_REPO_URI=`aws ecr describe-repositories --repository-names containers-lab1 --query 'repositories[*].repositoryUri' --output text`
# Authenticate to ECR repo
$(aws ecr get-login --registry-ids $ACCOUNT_NUMBER --no-include-email --region us-east-2)
# Tag docker image
docker tag stp/lab1:latest $ECR_REPO_URI:latest
# Push docker image to repo
docker push $ECR_REPO_URI:latest

"#!/bin/bash\n",
"exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1\n",
"# https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-log-user-data/\n",
"yum update -y\n",
"# Install Docker\n",
"amazon-linux-extras install docker\n",
"service docker start\n",
"usermod -a -G docker ec2-user\n",
"chkconfig docker on\n",
"# Download binaries\n",
"cd /home/ec2-user\n",
"curl -o fargatesetup.zip https://ee-assets-prod-us-east-1.s3.us-east-1.amazonaws.com/modules/2160a6f9d46f4474ae62edd1e48c1d5b/v1/fargatesetup.zip\n",
"unzip fargatesetup.zip\n",
"# Build docker image\n",
"docker build -t stp/lab1 .\n",
"# Create ECR repo\n",
"aws ecr create-repository --repository-name containers-lab1 --region us-east-2\n",
"# Environment variables\n",
"export AWS_DEFAULT_REGION=us-east-2\n",
"export ACCOUNT_NUMBER=`aws sts get-caller-identity --query 'Account' --output text`\n",
"export ECR_REPO_URI=`aws ecr describe-repositories --repository-names containers-lab1 --query 'repositories[*].repositoryUri' --output text`\n",
"# Authenticate to ECR repo\n",
"$(aws ecr get-login --registry-ids $ACCOUNT_NUMBER --no-include-email --region us-east-2)\n",
"# Tag docker image\n",
"docker tag stp/lab1:latest $ECR_REPO_URI:latest\n",
"# Push docker image to repo\n",
"docker push $ECR_REPO_URI:latest\n"

