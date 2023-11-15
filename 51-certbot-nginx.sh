#!/bin/bash

source shared.sh

dotenv

if install_packages certbot python3-certbot-nginx; then
    echo "Running configuration for certbot on $CERTBOT_DOMAIN notifying $CERTBOT_EMAIL"
    sudo certbot certonly --nginx -d "$CERTBOT_DOMAIN" -m "$CERTBOT_EMAIL" --agree-tos --non-interactive
    restart_service nginx
fi
