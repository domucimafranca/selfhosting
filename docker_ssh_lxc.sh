#!/bin/bash

# set error handling; exit script on any error
set -e

# set default flavor
FLAVOR="ubuntu:24.04"

# instructions
if [ $# -eq 0 ]; then
  echo "Usage: $0 <container_name>"
  echo "   Creates an LXC container with the specified name."
  echo "   Default flavor is $FLAVOR"
  echo "   It then copies your authorized_keys to the new container."
  echo
  echo "   Example: $0 my_container"
  exit 1
fi

CONTAINER_NAME="$1"

# Create the LXC container for Docker
lxc launch $FLAVOR $CONTAINER_NAME
lxc storage volume create docker "${CONTAINER_NAME}_fs"
lxc config device add "$CONTAINER_NAME" docker \
  disk pool=docker source="${CONTAINER_NAME}_fs" path=/var/lib/docker
lxc config set "$CONTAINER_NAME" security.nesting=true
lxc config set "$CONTAINER_NAME" security.syscalls.intercept.mknod=true
lxc config set "$CONTAINER_NAME" security.syscalls.intercept.setxattr=true

# Get the current user on the host system
HOST_USER=$(id -un)

# Create the user on the LXC guest
lxc exec $CONTAINER_NAME -- useradd -m -s /bin/bash $HOST_USER
lxc exec $CONTAINER_NAME -- usermod -aG sudo $HOST_USER


# Prompt for the password for the new user
read -s -p "Enter password for $HOST_USER on the LXC guest: " PASSWORD
echo

# Set the password for the new user
lxc exec $CONTAINER_NAME -- echo "$HOST_USER:$PASSWORD" | lxc exec $CONTAINER_NAME -- chpasswd

# Copy the authorized_keys file from the host to the guest
lxc exec $CONTAINER_NAME -- mkdir -p /home/$HOST_USER/.ssh
lxc file push ~/.ssh/authorized_keys $CONTAINER_NAME/home/$HOST_USER/.ssh/authorized_keys
lxc exec $CONTAINER_NAME -- chown $HOST_USER:$HOST_USER /home/$HOST_USER/.ssh/authorized_keys

echo "LXC container '$CONTAINER_NAME' created with user '$HOST_USER'."


