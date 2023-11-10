#!/bin/bash

source shared.sh

request_confirmation "Update packages" && \
	DEBIAN_FRONTEND=noninteractive sudo apt-get update -y > /dev/null && \
	DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y > /dev/null

echo

install_packages curl openssl ca-certificates

echo

if install_packages ntp; then
    backup_file /etc/ntpsec/ntp.conf && \
	echo "Editing ntp configuration"
        sudo sed -i -r -e "s/^((server|pool).*)/# \1$(commented_by)/" /etc/ntpsec/ntp.conf > /dev/null && \
        echo -e "\npool pool.ntp.org iburst$(added_by)" | sudo tee -a /etc/ntpsec/ntp.conf > /dev/null
	restart_service ntp
fi

echo

if install_packages rng-tools; then
	echo "Editing rng-tools configuration"
    echo "HRNGDEVICE=/dev/urandom$(added_by)" | sudo tee -a /etc/default/rng-tools > /dev/null
	restart_service rng-tools
fi
