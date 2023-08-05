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
yes N | apt-get install -y nginx

# Wait for Radarr to create config files on first start
RADARR_IS_UP=""
for i in $(seq 60)
do
    echo "Attempt #${i} to check if radarr is up"
    if curl -sf http://localhost/radarr >/dev/null
    then
        RADARR_IS_UP="1"
        break
    else
        sleep 10
    fi
done

if [ ! $RADARR_IS_UP ]
then
    echo "Radarr failed to start in 5 minutes, aborting"
    exit 1
fi
