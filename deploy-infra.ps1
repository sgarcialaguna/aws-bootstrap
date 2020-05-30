Compress-Archive -Path start-service.sh,stop-service.sh,appspec.yml -DestinationPath scripts.zip -Force
aws s3 cp scripts.zip s3://sgarcia-aws-bootstrap-scripts/
docker build -t aws_bootstrap .
docker tag aws_bootstrap:latest 061199822233.dkr.ecr.eu-central-1.amazonaws.com/aws_bootstrap:latest
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 061199822233.dkr.ecr.eu-central-1.amazonaws.com
docker push 061199822233.dkr.ecr.eu-central-1.amazonaws.com/aws_bootstrap:latest
