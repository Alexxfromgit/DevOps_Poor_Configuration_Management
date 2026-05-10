#!/bin/bash

if [ -z "$(service ntp status | grep -w active)" ]; then
    echo 'NOTICE: ntp is not running'
    service ntp start
fi

if [ ! -f "/etc/ntp.conf" ] && [ ! -f "/etc/ntp.conf.bak" ]; then
    echo 'NOTICE: ups...restore ntp service'
    apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall ntp >> /dev/null 2>&1
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
    bash "${SCRIPT_DIR}/ntp_deploy.sh"
    exit $?
fi

if [ ! -f "/etc/ntp.conf.bak" ]; then
    cp /etc/ntp.conf /etc/ntp.conf.bak
    echo 'NOTICE: bak file restore'
fi

if [ ! -f "/etc/ntp.conf" ]; then
    cp /etc/ntp.conf.bak /etc/ntp.conf
    echo 'NOTICE: conf file restore'
fi

if [ -n "$(diff /etc/ntp.conf.bak /etc/ntp.conf)" ]; then
    echo 'NOTICE: /etc/ntp.conf was changed. Calculated diff:'
    diff -U0 /etc/ntp.conf.bak /etc/ntp.conf
    cp /etc/ntp.conf.bak /etc/ntp.conf
    service ntp restart
fi
