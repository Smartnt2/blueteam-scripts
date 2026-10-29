#!/usr/bin/env sh

if [[ $EUID -ne 0 ]]; then
    echo "run as root"
    exit 1
fi

if [[ -x $(command -v ufw) ]]; then
    echo "installing ufw"
    apt install ufw
fi

ufw logging on
ufw default deny incoming
ufw default allow outgoing

#ssh
ufw limit 6767
#ftp
ufw limit 4444
#sql
ufw limit 333

ufw allow from 10.10.1.0/24
ufw allow from 192.168.10.0/24

ufw enable
ufw status verbose
