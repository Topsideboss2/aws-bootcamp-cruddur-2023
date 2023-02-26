#!/usr/bin/bash
cd /home/ubuntu/
echo "Now in home directory"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
echo "Installed curl"
apt install unzip -y
echo "Installed unzip"
unzip awscliv2.zip
echo "awscliv2.zip is unzipped"
rm awscliv2.zip
cd /home/ubuntu/aws-bootcamp-cruddur-2023/backend-flask/
apt install python3-pip -y
pip3 install -r requirements.txt
export FRONTEND_URL="*"
export BACKEND_URL="*"
echo "Backend initialized"
cd /home/ubuntu/aws-bootcamp-cruddur-2023/frontend-react-js/
export REACT_APP_BACKEND_URL="http://127.0.0.1:4567"
apt update 
apt install npm -y
npm install
echo "installed npm so frontend is initialized"
echo "install docker"
cd /home/ubuntu/aws-bootcamp-cruddur-2023/
apt install docker.io
apt install docker-compose
