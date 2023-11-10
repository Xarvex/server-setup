#!/bin/bash

source shared.sh

# apt-listchanges has graphical config
install_packages unattended-upgrades apticron apt-listchanges

echo "Creating configuration for apt with unattended-upgrades"
sudo touch /etc/apt/apt.conf.d/51myunattended-upgrades
cat << EOF | sudo tee /etc/apt/apt.conf.d/51myunattended-upgrades
APT::Periodic::Enable "1";

APT::Periodic::Update-Patckage-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";

Unattended-Upgrade::Origins-Pattern {
    "o=Debian,a=stable";
    "o=Debian,a=stable-updates";
    "origin=Debian,codename=${distro_codename},lavel=Debian-Security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::InstallOnShutdown "false";
Unattended-Upgrade::Mail "root";
Unattended-Upgrade::MailOnlyOnError "false";

Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";

Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
EOF

echo "Creating configuration for apticron"
sudo touch /etc/apticron/apticron.conf
cat << EOF | sudo tee /etc/apticron/apticron.conf
EMAIL="root"
NOTIFY_NO_UPDATES="1"
EOF

echo "Testing unattended-upgrade"
sudo unattended-upgrade -d --dry-run
echo "Running configuration for apt-listchanges"
sudo dpkg-reconfigure apt-listchanges
