#!/bin/bash

set -e -o pipefail

# Install docker

## Update the apt package index and install packages to allow apt to use a repository over HTTPS:
apt-get update
apt-get install -y ca-certificates curl gnupg

## Add Docker’s official GPG key:
install -m 0755 -d /usr/share/keyrings/
rm -rf /usr/share/keyrings/docker-archive-keyring.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
chmod 544 /usr/share/keyrings/docker-archive-keyring.gpg

## Set up the deb repository:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## Install Docker Engine
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure docker compose systemd unit
cat >/etc/systemd/system/docker-compose-app.service <<EOF
[Unit]
Description=Docker Compose
Requires=docker.service
After=docker.service

[Service]
RemainAfterExit=yes
WorkingDirectory=/scripts
ExecStart=docker compose up
ExecStop=docker compose down
TimeoutStartSec=0
Restart=on-failure
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

systemctl enable docker-compose-app
systemctl start docker-compose-app

# Install nginx (configuration is in synced_dirs)
## (it fails on repeated installs for some reason, mute)
yes N | apt-get install -y nginx || true


# Set base URL to make it work with nginx subdirectories

## Wait for Radarr to create config file on first start and edit it
until [ -f /configs/radarr/config.xml ]; do sleep 1; done
sed -i 's#<UrlBase></UrlBase>#<UrlBase>/radarr</UrlBase>#' /configs/radarr/config.xml

## Wait for Sonarr to create config file on first start and edit it
until [ -f /configs/sonarr/config.xml ]; do sleep 1; done
sed -i 's#<UrlBase></UrlBase>#<UrlBase>/radarr</UrlBase>#' /configs/sonarr/config.xml

## Wait for Jackett to create config file on first start and edit it
until [ -f /configs/jackett/Jackett/ServerConfig.json ]; do sleep 1; done
sed -i 's#"BasePathOverride": null,#"BasePathOverride": "/jackett",#' /configs/jackett/Jackett/ServerConfig.json

systemctl restart docker-compose-app
