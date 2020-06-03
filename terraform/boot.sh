#!/bin/bash -xe

# send script output to /tmp so we can debug boot failures
exec > /tmp/userdata.log 2>&1
# Update all packages
yum -y update
yum install -y ruby jq wget aws-cli

# Install CodeDeploy agent
wget https://aws-codedeploy-eu-central-1.s3.amazonaws.com/latest/install -O /home/ec2-user/install-codedeployagent.sh
chmod +x /home/ec2-user/install-codedeployagent.sh
/home/ec2-user/install-codedeployagent.sh auto

# Install CloudWatch agent
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O /home/ec2-user/awslogs-agent-setup.py
wget https://s3.amazonaws.com/aws-codedeploy-us-east-1/cloudwatch/codedeploy_logs.conf -O /home/ec2-user/codedeploy_logs.conf
chmod +x /home/ec2-user/awslogs-agent-setup.py
python /home/ec2-user/awslogs-agent-setup.py -n -r eu-central-1 -c s3://aws-codedeploy-us-east-1/cloudwatch/awslogs.conf
cat /home/ec2-user/codedeploy_logs.conf >> /var/awslogs/etc/awslogs.conf
service awslogs restart