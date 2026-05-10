#!/bin/bash

apt-get update >> /dev/null 2>&1 && apt-get install -y ntp >> /dev/null 2>&1

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sed -i '/ntp_verify.sh/d' /etc/crontab
sed -i '/ua.pool.ntp.org/d' /etc/ntp.conf
sed -i 's/^pool/#pool/g' /etc/ntp.conf
sed -i 's/^server/#server/g' /etc/ntp.conf
echo "pool ua.pool.ntp.org iburst" >> /etc/ntp.conf

if [ -f /etc/ntp.conf.bak ]; then rm -f /etc/ntp.conf.bak; fi
cp /etc/ntp.conf /etc/ntp.conf.bak

service ntp restart

chmod +x "${SCRIPT_DIR}/ntp_verify.sh"
echo "* * * * *   root    ${SCRIPT_DIR}/ntp_verify.sh" >> /etc/crontab
