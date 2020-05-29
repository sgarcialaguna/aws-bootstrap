#!/bin/bash -xe

# send script output to /tmp so we can debug boot failures
exec > /tmp/userdata.log 2>&1
# Update all packages
yum -y update
yum install -y ruby jq wget aws-cli
wget https://aws-codedeploy-eu-central-1.s3.amazonaws.com/latest/install -O /home/ec2-user/install-codedeployagent.sh
chmod +x /home/ec2-user/install-codedeployagent.sh
/home/ec2-user/install-codedeployagent.sh auto
