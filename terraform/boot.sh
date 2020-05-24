#!/bin/bash -xe

# send script output to /tmp so we can debug boot failures
exec > /tmp/userdata.log 2>&1
# Update all packages
yum -y update
yum install -y ruby jq
wget https://aws-codedeploy-eu-central-1.s3.amazonaws.com/latest/install -O /home/ec2-user/install-codedeployagent.sh
chmod +x /home/ec2-user/install-codedeployagent.sh
/home/ec2-user/install-codedeployagent.sh auto
cat > /tmp/install_script.sh << EOF 
# START
echo "Setting up NodeJS Environment"
curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

# Dot source the files to ensure that variables are available within the current shell
. /home/ec2-user/.nvm/nvm.sh
. /home/ec2-user/.bashrc

# Install NVM, NPM, Node.JS
nvm alias default v12.7.0
nvm install v12.7.0
nvm use v12.7.0

npm install -g yarn
    
# Create log directory
mkdir -p /home/ec2-user/app/logs
EOF

chown ec2-user:ec2-user /tmp/install_script.sh && chmod a+x /tmp/install_script.sh
sleep 1;
su - ec2-user -c "/tmp/install_script.sh"
