#!/usr/bin/bash
cd /home/ubuntu/
echo "Now in home directory"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
echo "Installed curl"
apt install unzip
echo "Installed unzip"
unzip awscliv2.zip
echo "awscliv2.zip is unzipped"
cd /home/ubuntu/aws-bootcamp-cruddur-2023/
