#!/bin/bash
REGION="us-east-2"
IMAGE_NAME="keycloak"
MODULE_PATH=$MODULE_PATH
aws ecr get-login-password --region $REGION --profile $PROFILE | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
docker build -t $IMAGE_NAME:latest  $MODULE_PATH/../../../customization/
docker tag $IMAGE_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest