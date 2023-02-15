#!/bin/bash
echo "Starting the script..."

# Update apt package index
sudo apt-get update

# Install Node.js dependencies
sudo apt-get install -y curl

# Remove existing docker
sudo apt-get remove docker docker-engine docker.io containerd runc -y

# Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

# Add Docker’s official GPG key
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#Use the following command to set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index
sudo apt-get update

# Install Docker Engine, containerd, and Docker Compose
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "Installed Docker"

# Download and setup the Node.js 16 repository
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -

# Install Node.js and npm
sudo apt-get install -y nodejs

echo "Installed Nodejs"

# Verify the installation by checking the Node.js and npm version
node -v
npm -v

#download engineerman piston
cd ~

# clone and enter repo
git clone https://github.com/engineer-man/piston

echo "Cloned the Piston"

# # clone the config-files from gouseferoz github
# git clone https://github.com/gouseferoz/config-files.git

# echo "Cloned the Config Files"

cp /root/config-files/docker-compose.yaml /root/piston/

# Open piston folder and run docker compose command
# Start the API container
docker-compose up -d api

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

sudo ufw enable

sudo unlink /etc/nginx/sites-enabled/default

cp /root/config-files/reverse-proxy.conf /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

service nginx configtest

service nginx restart

echo "Installing Piston"

# install all the piston languages

cd /root/piston

cli/index.js ppman install python && cli/index.js ppman install gcc && cli/index.js ppman install java &&	cli/index.js ppman install dotnet && cli/index.js ppman install typescript &&	cli/index.js ppman install scala &&	cli/index.js ppman install rscript &&	cli/index.js ppman install sqlite3 && cli/index.js ppman install node