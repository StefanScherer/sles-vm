# Packer templates for SuSE Enterprise Linux (SLES)

### Overview

This repository contains templates for SLES that can create Vagrant boxes
using Packer.

## Current Boxes

64-bit boxes:

* SLES 11 SP 3

## Building the Vagrant boxes

To build all the boxes, you will need Packer ([Website](packer.io)) 
and both VirtualBox and VMware Fusion installed.

    ./build-sles11sp3_virtualbox.sh
    ./build-sles11sp3_vcloud.sh
    ./build-sles11sp3_vmware.sh
    
### Tests

TBD.
The tests are written in [Serverspec](http://serverspec.org) and require the
`vagrant-serverspec` plugin to be installed with:

    vagrant plugin install vagrant-serverspec

