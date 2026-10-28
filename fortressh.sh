#!/usr/bin/env sh

if [[ $EUID -ne 0 ]]; then
    echo "run as root"
    exit 1
fi

read -p "did u setup ssh keys?[yes/no i forgor]" option
if [[ $option -ne "yes" ]]; then
    exit 1
fi

SSHD = "/etc/ssh/sshd_config"

echo "making backup"
cp "$SSHD" "/etc/ssh/sshd_config.bak"
echo "backup at /etc/ssh/sshd_config.bak"

sshd_handler() {
    local option="$1"
    local val="$2"

    if grep -qE "^#?${option}\b" "$SSHD"; then
        sed -iE "s/^#?${option}\b.*/${option} ${val}/" "$SSHD"
    else
        echo "${option} ${val}" >> "$SSHD"
    fi
}

echo "changing config"
sshd_handler "Port" "6767"
ufw limit 6767/tcp
ufw deny 22
ufw reload
sshd_handler "PasswordAuthentication" "no"
sshd_handler "PubkeyAuthentication" "yes"
sshd_handler "Authentication Methods" "publickey"
sshd_handler "PermitRootLogin" "no"
sshd_handler "MaxAuthTries" "1"
sshd_handler "LoginGraceTime" "30"

echo "restarting daemon"
systemctl restart sshd
echo "yo that shit is hard now"
