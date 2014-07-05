#!/bin/bash
#if [ ! -d box/vmware ]; then
#  mkdir -p box/vmware
#fi
packer build --only=vmware-iso sles11sp3.json
