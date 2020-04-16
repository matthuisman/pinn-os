#!/bin/sh
#supports_backup in PINN

set -x

vfat_part=$part1
ext4_part=$part2
if [ -n $id1 ]; then vfat_part=$id1; fi
if [ -n $id2 ]; then ext4_part=$id2; fi

mkdir -p /tmp/1
mount "$part1" /tmp/1
sed /tmp/1/cmdline.txt -i -e "s|dev=[^ ]*|dev=${vfat_part}|"
umount /tmp/1