#!/bin/bash

source shared.sh

guard_authorized_keys

sshd_modified=0
append_sshd_settings() {
    backup_file /etc/ssh/sshd_config
	echo -e "Adding settings to sshd:\n$1\n"
	sudo sed -i "1s/^/$1\n\n/" /etc/ssh/sshd_config > /dev/null
	export sshd_modified=1
}

if request_confirmation "Lock down SSH access"; then
	append_sshd_settings "ClientAliveCountMax 0\nLoginGraceTime 30\nMaxAuthTries 2\nMaxSessions 2\nMaxStartups 2\nPasswordAuthentication no"
fi
if request_confirmation "Restrict SSH usage to sshusers group"; then
	create_group sshusers
	append_sshd_settings "AllowGroups sshusers"
fi
if request_confirmation "Add a warning banner on login"; then
    cat << EOF | sudo tee /etc/issue
----------------------------------------------------------------------------------------------
You are accessing a Xarvex Botworks (XB) Information System (IS) that is provided for authorized use only.
By using this IS (which includes any device attached to this IS), you consent to the following conditions:

+ The XB routinely intercepts and monitors communications on this IS for purposes including, but not limited to,
penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM),
law enforcement (LE), and counterintelligence (CI) investigations.

+ At any time, the XB may inspect and seize data stored on this IS.

+ Communications using, or data stored on, this IS are not private, are subject to routine monitoring,
interception, and search, and may be disclosed or used for any XB authorized purpose.

+ This IS includes security measures (e.g., authentication and access controls) to protect XB interests--not
for your personal benefit or privacy.

+ Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching
or monitoring of the content of privileged communications, or work product, related to personal representation
or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work
product are private and confidential. See User Agreement for details.
----------------------------------------------------------------------------------------------
EOF
    append_sshd_settings "Banner \/etc\/issue"
fi
if [ "$sshd_modified" ]; then
	restart_service sshd
fi

echo

if request_confirmation "Remove less secure moduli"; then
    backup_file /etc/ssh/moduli
	echo "Removing short moduli (less than 3072 bits)"
	sudo awk '$5 >= 3071' /etc/ssh/moduli | sudo tee /etc/ssh/moduli.tmp > /dev/null
	sudo mv /etc/ssh/moduli.tmp /etc/ssh/moduli
fi
