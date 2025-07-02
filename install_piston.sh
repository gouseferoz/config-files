#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${RED}Starting the Script...${NC}"

cd ~

# Update apt package index
sudo apt-get update

# Install Node.js dependencies
sudo apt-get install -y curl

# Remove existing docker

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker Engine, containerd, and Docker Compose
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo -e "${GREEN}Installed Docker${NC}"

# Download and setup the Node.js 16 repository
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Install Node.js and npm
sudo apt-get install -y nodejs

echo -e "${GREEN}Installed Nodejs${NC}"

# Verify the installation by checking the Node.js and npm version
node -v
npm -v

#download engineerman piston
cd ~

# clone and enter repo
git clone https://github.com/engineer-man/piston

echo -e "${GREEN}Cloned the Piston${NC}"

# # clone the config-files from gouseferoz github
# git clone https://github.com/gouseferoz/config-files.git

# echo "Cloned the Config Files"

cp /root/config-files/docker-compose.yaml /root/piston/

# Open piston folder and run docker compose command
# Start the API container
cd piston
docker compose up -d api

# Install all the dependencies for the cli
cd cli && npm i && cd ~

# Update apt package index
sudo apt-get update

# Install Nginx
sudo apt-get install nginx -y

# Stop Nginx service
sudo systemctl stop nginx

sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'ssh'

sudo ufw enable -y

echo -e "${GREEN}Installing Piston${NC}"

# install all the piston languages

cd /root/piston

cli/index.js ppman install python && cli/index.js ppman install gcc && cli/index.js ppman install java &&	cli/index.js ppman install dotnet && cli/index.js ppman install typescript &&	cli/index.js ppman install scala &&	cli/index.js ppman install rscript &&	cli/index.js ppman install sqlite3 && cli/index.js ppman install node && cli/index.js ppman install ruby && cli/index.js ppman install python=3.10.0 && cli/index.js ppman install go

sudo unlink /etc/nginx/sites-enabled/default

cp /root/config-files/reverse-proxy.conf /etc/nginx/sites-available/

echo -e "${GREEN}Copied the Reverse Proxy file${NC}"

sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

service nginx configtest

service nginx restart

echo -e "${GREEN}Restarted the NGINX${NC}"

cd ~
cd piston
docker compose down
docker compose up -d api

echo -e "${GREEN}Restarted the Docker${NC}"
