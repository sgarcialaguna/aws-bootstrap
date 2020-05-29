#!/bin/bash -xe
docker login --username AWS --password $(aws ecr get-login-password --region eu-central-1) 061199822233.dkr.ecr.eu-central-1.amazonaws.com
docker pull 061199822233.dkr.ecr.eu-central-1.amazonaws.com/aws_bootstrap:latest
docker run -d -p 8081:8081 061199822233.dkr.ecr.eu-central-1.amazonaws.com/aws_bootstrap:latest