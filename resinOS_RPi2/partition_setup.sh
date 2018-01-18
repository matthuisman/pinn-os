#!/bin/sh

set -x

vfat_part=$part1
ext4_part=$part2
if [ -n $id1 ]; then vfat_part=$id1; fi
if [ -n $id2 ]; then ext4_part=$id2; fi

#p1=`echo ${part1} | sed -e 's/dev/dev\/block/g'`

mkdir -p /tmp/1
mount "$part1" /tmp/1
sed /tmp/1/cmdline.txt -i -e "s|root=[^ ]*|root=${ext4_part}|"
#sed /tmp/1/device-type.json -i -e "s|\"primary\": [0-9]*|\"primary\": ${p1}|"
umount /tmp/1
