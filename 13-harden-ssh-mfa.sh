#!/bin/bash

source shared.sh

if install_packages libpam-google-authenticator; then
	echo "Running configuration for google-authenticator"
	google-authenticator
	echo "Adding google-authenticator in PAM SSH"
    echo -e "\nauth required pam_google_authenticator.so nullok\nauth required pam_permit.so$(added_by)" | sudo tee -a /etc/pam.d/sshd
	sshd_challenge="AuthenticationMethods publickey,keyboard-interactive publickey,password\nChallengeResponseAuthentication yes"
    backup_file /etc/ssh/sshd_config
    backup_file /etc/pam.d/sshd
	echo -e "Adding PAM to sshd:\n$sshd_challenge"
	sudo sed -i "1s/^/$sshd_challenge\n/" /etc/ssh/sshd_config
    sudo sed -i -r -e "s/^(@include common-auth)$/# \1$(added_by)/" /etc/pam.d/sshd
	restart_service sshd
fi
