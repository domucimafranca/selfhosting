#!/bin/bash

# Note: execute the script as sudo
# We assume that you already have ssh key access to the system.
# Reboot the system for secure shared memory to take effect.

# set error handling; exit script on any error
set -e

# update apt
apt-get update

# expire the root password
passwd -l root

# backup the sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# don't permit root logins
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# disable sshd password authentication
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config

# install fail2ban
apt-get install fail2ban -y
cat << EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

# secure shared memory
echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab

# enable the firewall
ufw enable
ufw allow ssh
ufw allow http
ufw allow https
