# Setting up LXD on Ubuntu 24.04 with local network VMs
We want to set up a new server that can host virtual machines using [LXD](https://canonical.com/lxd) so we can run [Linux containers](https://linuxcontainers.org/).  The process for LXD itself is quite straightforward for Ubuntu.  However, by default, the resulting Linux containers are given private IP addreses by the built-in bridge.  We want to modify this behavior so Linux containers have IP addresses served by the DHCP server of the host network.

## Online references
* https://documentation.ubuntu.com/lxd/en/latest/tutorial/first_steps/
* https://blog.simos.info/how-to-make-your-lxd-containers-get-ip-addresses-from-your-lan-using-a-bridge/
* https://ubuntu.com/tutorials/how-to-run-docker-inside-lxd-containers#1-overview

## Scripts
* [lxc_vanilla_ssh.sh](lxc_vanilla_ssh.sh)
* [lxc_docker_ssh.sh](lxc_docker_ssh.sh)
* [install_docker.ssh](../general/install_docker.sh)

# Instructions

## Basic setup of LXD
On a freshly installed Ubuntu 24.04 server, all we need to install LXD are the following commands: 
```
sudo apt update
sudo apt upgrade

snap version
sudo snap install lxd
sudo snap refresh lxd
```

As an added step, we want to make sure that the user is a member of the `lxd` group:

```
getent group lxd | grep "$USER"
```

Then, to initialize lxd:
```
lxd init --minimal
```

Launching the first VM --
```
lxc launch ubuntu:24.04 c1
```

## Setting up the bridge network for VMs
 
### The bridge interface
We want to set up our own bridge interface to connect our physical LXD environment to the local network.  This is where the existing documentation on the Internet is a bit unclear.  What follows is my simplified version.

In the first place, there's no need to install bridge-utils, etc.  We just need to set the bridge up on Netplan through the main configuration file `/etc/netplan/50-cloud-init.yaml`

```
network:
    ethernets:
        enp0s31f6:
            dhcp4: false
    bridges:
        office_br0:
            dhcp4: true
            interfaces: [enp0s31f6]
    version: 2
```

The above configuration will create a bridge called `office_br0`.

Reboot for the changes to take effect.  After bootup, the network configuration should now look like this:

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s31f6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master office_br0 state UP group default qlen 1000
    link/ether b8:85:84:9b:35:6a brd ff:ff:ff:ff:ff:ff
3: office_br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 36:6d:5c:74:48:d3 brd ff:ff:ff:ff:ff:ff
    inet 192.168.88.67/24 metric 100 brd 192.168.88.255 scope global dynamic office_br0
       valid_lft 81564sec preferred_lft 81564sec
    inet6 fe80::346d:5cff:fe74:48d3/64 scope link 
       valid_lft forever preferred_lft forever
4: lxdbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 00:16:3e:bc:29:95 brd ff:ff:ff:ff:ff:ff
    inet 10.121.100.1/24 scope global lxdbr0
       valid_lft forever preferred_lft forever
    inet6 fd42:6a28:c9a9:1fe6::1/64 scope global 
       valid_lft forever preferred_lft forever
```

### Creating a bridged profile for LXD
It might still be useful for some VMs to have an internal IP address rather than a local network IP address.  For this reason, we'll create a separate profile called `bridged` and invoke that explicitly when we need a local network address.

```
lxc profile create bridged
lxc profile edit bridged
```

Then set the profile to the following --

```
name: bridged
description: Bridged LXD profile
config: {}
devices:
  eth0:
    name: eth0
    nictype: bridged
    parent: office_br0
    type: nic
```

Now, to launch a bridged VM with a local network DHCP address

```
lxc launch -p default -p bridged ubuntu:24.04 c1
```

Container c1 will now be a bridged vm!  

To simplify setting up a bridged VM, I made a [helper script](lxc_vanilla_ssh.sh).  This script sets up ssh keys for easier and more secure access.


## Running Docker on the VMs
There are [a few things to set up](https://ubuntu.com/tutorials/how-to-run-docker-inside-lxd-containers#1-overview) so that the VMs can run Docker correctly.  In the main, we want Docker-enabled VMs to use btrfs.  So ---

```
lxc storage create docker btrfs
```

This creates a btrfs volume called `docker.`

There are a few more commands after this to get Docker to run properly, the main one being to attach the docker volume to the VM.  All this is simplified by using a [helper script for Docker VMs](lxc_docker_ssh.sh). You will still need to install Docker, though, but you can simplify the process by using the [install_docker.sh](../general/install_docker.sh) script.

You can see the docker volumes using the command `lxc storage volume list`.  The result --
```
+---------+-----------+-------+-------------+--------------+---------+
|  POOL   |   TYPE    | NAME  | DESCRIPTION | CONTENT-TYPE | USED BY |
+---------+-----------+-------+-------------+--------------+---------+
| default | container | d1    |             | filesystem   | 1       |
+---------+-----------+-------+-------------+--------------+---------+
| default | container | v1    |             | filesystem   | 1       |
+---------+-----------+-------+-------------+--------------+---------+
| docker  | custom    | d1_fs |             | filesystem   | 1       |
+---------+-----------+-------+-------------+--------------+---------+
```

When you delete the Docker-enabled volume (`d1` in the example above), it is best if you also delete the associated volume (`d1_fs` in this case).  The command is

```
lxc storage volume delete docker d1_fs
```
