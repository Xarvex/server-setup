#!/bin/bash

source shared.sh

dotenv

if install_packages exim4; then
    backup_file /etc/mailname
    backup_file /ect/exim4/update-exim4.conf.conf
    echo "Setting mailname as localhost"
    echo "localhost" | sudo tee /etc/mailname
    echo "Configuring exim4"
    cat << EOF | sudo tee /etc/exim4/update-exim4.conf.conf
dc_eximconfig_configtype='satellite'
dc_other_hostnames='$(hostname)'
dc_local_interfaces='127.0.0.1 ; ::1'
dc_readhost='localhost'
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets=''
dc_smarthost='$SOURCE_EMAIL_PROV:$SOURCE_EMAIL_PROV_PORT'
CFILEMODE='644'
dc_use_split_config='false'
dc_hide_mailname='true'
dc_mailname_in_oh='true'
dc_localdelivery='mail_spool'
EOF
	sudo update-exim4.conf

	echo "Adding credentials for exim4"
	echo -e "$SOURCE_EMAIL_PROV:$SOURCE_EMAIL_ADR:$SOURCE_EMAIL_PWD\n$SOURCE_EMAIL_PROV_ALT:$SOURCE_EMAIL_ADR:$SOURCE_EMAIL_PWD" | sudo tee -a /etc/exim4/passwd.client
	sudo chown root:Debian-exim /etc/exim4/passwd.client
	sudo chmod 640 /etc/exim4/passwd.client

	echo "Creating TLS certificate for exim4"
	sudo bash /usr/share/doc/exim4-base/examples/exim-gencert
	echo "Configuring TLS and fixing long lines for exim4"
	cat << EOF | sudo tee -a /etc/exim4/exim4.conf.localmacros
MAIN_TLS_ENABLE = 1
REMOTE_SMTP_SMARTHOST_HOSTS_REQUIRE_TLS = *
TLS_ON_CONNECT_PORTS = $SOURCE_EMAIL_PROV_PORT
REQUIRE_PROTOCOL = smtps
IGNORE_SMTP_LINE_LENGTH_LIMIT = true
EOF
    sudo sed -i -r -e '/^.ifdef REMOTE_SMTP_SMARTHOST_HOSTS_REQUIRE_TLS$/I { :a; n; /^.endif$/!ba; a'"$(added_by)"'\n.ifdef REQUIRE_PROTOCOL\n    protocol = REQUIRE_PROTOCOL\n.endif\n# end add' -e '}' /etc/exim4/exim4.conf.template
    sudo sed -i -r -e "/\.ifdef MAIN_TLS_ENABLE/ a$(added_by)\n.ifdef TLS_ON_CONNECT_PORTS\n    tls_on_connect_ports = TLS_ON_CONNECT_PORTS\n.endif\n# end add" /etc/exim4/exim4.conf.template

	echo "Updating exim4 configuration"
	sudo update-exim4.conf
	restart_service exim4

    backup_file /etc/aliases
    echo "Adding users to /etc/aliases"
    while :; do
        read -rp "Username: " alias_username
        read -rp "Email: " alias_email
        if [ -z "$alias_username" ] || [ -z "$alias_email" ]; then
            break
        fi
        echo "$alias_username: $alias_email" | sudo tee -a /etc/aliases
    done
	read -rp "Sending test mail with $SOURCE_EMAIL_ADR to: " destination
	echo "Hello World!" | mail -s "Test" "$destination"
fi
