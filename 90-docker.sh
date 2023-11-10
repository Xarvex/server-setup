#!/bin/bash

echo "Installing docker"
sudo curl -sSL https://get.docker.com/ | CHANNEL=stable bash
echo "Starting docker on future boots"
sudo systemctl enable docker
echo "Append swapaccount=1 to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub"
echo "Make sure to run update-grub and reboot"
