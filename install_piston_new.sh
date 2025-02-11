#!/bin/bash

# Remove existing Docker packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove $pkg -y
done

# Add Docker's official GPG key
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo apt-get update
sudo apt-get install docker-compose-plugin -y

# Install Node.js
cd ~
curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh

# Clone and set up Piston
git clone https://github.com/engineer-man/piston
cd piston/cli && npm i && cd ~

# Install Nginx
sudo apt-get update
sudo apt-get install nginx -y

# Start Docker Compose API
docker compose up -d api

# Install required packages in Piston
cd /root/piston
cli/index.js ppman install python
cli/index.js ppman install gcc
cli/index.js ppman install java
cli/index.js ppman install dotnet
cli/index.js ppman install typescript
cli/index.js ppman install scala
cli/index.js ppman install rscript
cli/index.js ppman install sqlite3
cli/index.js ppman install node
cli/index.js ppman install ruby

# Configure Nginx reverse proxy
sudo unlink /etc/nginx/sites-enabled/default
cp /root/config-files/reverse-proxy.conf /etc/nginx/sites-available/
echo -e "${GREEN}Copied the Reverse Proxy file${NC}"
sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
service nginx configtest
service nginx restart
echo -e "${GREEN}Restarted the NGINX${NC}"

# Restart Piston Docker services
cd ~/piston
docker compose down
docker compose up -d api

# Copy Docker Compose configuration
cp /root/config-files/docker-compose.yaml /root/piston/

# Restart Piston Docker services again
cd /root/piston
docker compose down
docker compose up -d api
