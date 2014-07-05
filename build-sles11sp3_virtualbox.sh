#!/bin/bash
#if [ ! -d box/virtualbox ]; then
#  mkdir -p box/virtualbox
#fi
packer build --only=virtualbox-iso sles11sp3.json
