#!/bin/bash -eux

# remove NAME= field to allow different network card to appear
cat <<ETH0 > /etc/sysconfig/network/ifcfg-eth0 
BOOTPROTO='dhcp'
STARTMODE='auto'
USERCONTROL='no'
ETH0
