#!/bin/bash -eux

# http://www.vcritical.com/2010/10/getting-eth0-back-in-a-sles-for-vmware-clone/
grep -v eth /etc/udev/rules.d/70-persistent-net.rules >/tmp/net.rules
mv /tmp/net.rules /etc/udev/rules.d/70-persistent-net.rules

# remove NAME= field to allow different network card to appear
cat <<ETH0 > /etc/sysconfig/network/ifcfg-eth0 
BOOTPROTO='dhcp'
STARTMODE='auto'
USERCONTROL='no'
ETH0
