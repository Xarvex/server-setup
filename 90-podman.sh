#!/bin/bash

install_packages podman
echo "Starting podman on future boots"
sudo systemctl enable podman
echo "Append swapaccount=1 to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub"
echo "Make sure to run update-grub and reboot"
