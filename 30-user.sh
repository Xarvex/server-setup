#!/bin/bash

source shared.sh

echo "Creating user accounts"
while :; do
    read -rp "Username: " username
    if [ -z "$username" ]; then
        break
    fi
    sudo useradd -m "$username"
    [ "$(getent group sshusers)" ] &&
        request_confirmation "Give user SSH access" &&
        sudo usermod -a -G sshusers "$username"
done
