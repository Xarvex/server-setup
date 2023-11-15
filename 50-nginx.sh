#!/bin/bash

source shared.sh

if install_packages nginx; then
    request_confirmation "Remove any enabled sites" && sudo rm -f /etc/nxinx/sites-enabled/*
fi
