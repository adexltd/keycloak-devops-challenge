#!/bin/bash
ECR_REPO_NAME= "${aws_ecr_repository.outputs.name}"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --output text --query 'Account').dkr.ecr.us-east-1.amazonaws.com
ECR_REPO_URL=$(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --output text --query 'repositories[0].repositoryUri')
docker build -t ${var.image_name} .
docker tag $ECR_REPO_NAME:latest $ECR_REPO_URL:latest
docker push $ECR_REPO_URL/$ECR_REPO_NAME:latest