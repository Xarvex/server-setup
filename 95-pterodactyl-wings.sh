#!/bin/bash

autoconfigure=""
while getopts "a:" flag; do
  case "${flag}" in
    a) autoconfigure="${OPTARG}" ;;
    *) ;;
  esac
done

echo "Downloading wings"
sudo mkdir -p /etc/pterodactyl
sudo curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
sudo chmod u+x /usr/local/bin/wings
echo "Autoconfigure running"
sudo bash -c "$autoconfigure"

echo "Creating wings service"
cat << EOF | sudo tee /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

echo "Starting wings now and on boot"
sudo systemctl enable --now wings
