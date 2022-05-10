#!/bin/zsh

echo 'Creating Roger Skyline VM...'
VBoxManage createvm --name debian --ostype Debian_64 --register
VBoxManage modifyvm debian --memory 1024
VBoxManage modifyvm debian --vram 64

echo 'Creating virtual hard drive...'
VBoxManage createhd --filename ~/goinfre/cnysten/debian/debian.vdi --size 80000 --format VDI
VBoxManage storagectl debian --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach debian --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ~/goinfre/cnysten/debian/debian.vdi

echo 'Mounting ISO file...'
VBoxManage storagectl debian --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach debian --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium ~/debian-11.3.0-amd64-netinst.iso

echo 'Preparing to boot VM...'
VBoxManage modifyvm debian --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage modifyvm debian --vrde on

VBoxManage startvm debian
