#!/bin/ash

set -x

mkdir -p /tmp/mount

mount $part1 /tmp/mount
echo "root=${part2} rootfstype=ext4 elevator=deadline rootwait" > /tmp/mount/cmdline.txt
sed /tmp/mount/config/settings.ini -i -e "s|resize_once.*|resize_once = false|"
sed /tmp/mount/config/settings.ini -i -e "s|scan_always.*|scan_always = false|"
umount /tmp/mount
sync

mount $part2 /tmp/mount
echo "${id1}  /boot  vfat  defaults,user,rw,umask=000  0  2" > /tmp/mount/etc/fstab
umount /tmp/mount
sync
