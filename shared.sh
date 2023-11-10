#!/bin/bash

changed_by_default="changed"
changed_by_comment="commented"
changed_by_add="added"

dotenv() {
    set -o allexport
    source .env
    set +o allexport
}

request_confirmation() {
	read -rp "$([ -z "$1" ] && echo "Continue" || echo "$1")? (y/n): " confirm && [[ ${confirm^^} == 'Y' || ${confirm^^} == 'YES' ]] || return 1
}

install_packages() {
	local list
    list=$(echo "$@" | tr -s '[:blank:]' ', ')
	if request_confirmation "Install $list"; then
		echo "Installing $list"
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq -o=Dpkg::Use-Pty=0 $@ < /dev/null > /dev/null
	else
		return 1
	fi
}

restart_service() {
	echo "Restarting $1"
	sudo systemctl restart "$1"
}

backup_file() {
	echo "Creating backup for $1"
	sudo cp --archive "$1" "$1-$(date +"%Y-%m-%d-%T").bak"
}

changed_by() {
    echo "        # $([ -z "$1" ] && echo "$changed_by_default" || echo "$1") by $USER on $(date +"%Y-%m-%d @ %T")"
}
commented_by() {
	changed_by "$changed_by_comment"
}
added_by() {
	changed_by "$changed_by_add"
}

create_group() {
	echo "Creating group $1"
	sudo groupadd "$1"
	echo "Adding $USER to $1"
	sudo usermod -a -G "$1" "$USER"
}

has_authorized_keys() {
	[ -f "$HOME/.ssh/authorized_keys" ] || return 1
}
abort_no_authorized_keys() {
	echo "No SSH keys found at $HOME/.ssh/authorized_keys, aborting future operation"
	exit 1
}
guard_authorized_keys() {
	has_authorized_keys || abort_no_authorized_keys
}
