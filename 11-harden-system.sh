#!/bin/bash

source shared.sh

# Add: install usb-storage /bin/true to  /etc/modprobe.d/disable-usb-storage.conf
# Add blacklist firewire-core  to /etc/modprobe.d/firewire.conf
# Add blacklist thunderbolt  to /etc/modprobe.d/thunderbolt.conf

if request_confirmation "Limit su usage to suuser group"; then
	create_group suusers
	echo "Limiting su to suuser"
	sudo dpkg-statoverride --update --add root suusers 4750 /bin/su
fi

echo

if install_packages libpam-pwquality; then
	echo "Adding pwquality in PAM common-password"
    sudo sed -i -r -e "s/^(password\s+requisite\s+pam_pwquality.so)(.*)$/# \1\2$(commented_by)\n\1 retry=3 minlen=10 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 maxrepeat=3 gecoschec$(added_by)/" /etc/pam.d/common-password > /dev/null
fi

echo

echo "This next install will take some time"
install_packages firejail firejail-profiles
