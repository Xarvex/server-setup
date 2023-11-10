#!/bin/bash

email="letsencrypt.taegy@simplelogin.com"

domain=""
while getopts "d:e:" flag; do
  case "${flag}" in
    d) domain="${OPTARG}" ;;
    *) ;;
  esac
done

install_packages nginx certbot python3-certbot-nginx
echo "Removing any enabled sites"
sudo rm -f /etc/nxinx/sites-enabled/*
echo "Running configuration for certbot on $domain notifying $email"
sudo certbot certonly --nginx -d "$domain" -m "$email" --agree-tos --non-interactive
restart_service nginx

echo "Adding certbot renew schedule in cron"
croncmd="certbot renew --quiet --deploy-hook \"systemctl restart nginx\""
cronjob="0 0 * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" || : ; echo "$cronjob" ) | crontab -
