#!/bin/sh
#supports_backup in PINN

set -ex

mkdir -p /tmp/1 /tmp/2

mount "$part1" /tmp/1
mount "$part2" /tmp/2

echo "root=${part2} rootfstype=ext4 elevator=deadline rootwait" > /tmp/1/cmdline.txt
sed /tmp/1/config/settings.ini -i -e "s|resize_once.*|resize_once = false|"
sed /tmp/1/config/settings.ini -i -e "s|scan_always.*|scan_always = false|"

echo "${id1} /boot vfat defaults,user,rw,umask=000 0 2" > /tmp/2/etc/fstab

umount /tmp/1
umount /tmp/2
