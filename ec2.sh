#!/usr/bin/bash
cd /home/ubuntu/
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="Now in home directory"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="Installed curl"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
apt install unzip -y
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="Installed unzip"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
unzip awscliv2.zip
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="awscliv2.zip is unzipped"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
rm awscliv2.zip
cd /home/ubuntu/aws-bootcamp-cruddur-2023/backend-flask/
apt install python3-pip -y
pip3 install -r requirements.txt
export FRONTEND_URL="*"
export BACKEND_URL="*"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="Backend initialized"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
cd /home/ubuntu/aws-bootcamp-cruddur-2023/frontend-react-js/
export REACT_APP_BACKEND_URL="http://3.220.231.46:4567"
apt update 
apt install npm -y
npm install
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="installed npm so frontend is initialized"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="install docker"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
cd /home/ubuntu/aws-bootcamp-cruddur-2023/
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="Installing docker"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
apt install docker.io
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="installing docker-compose"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
