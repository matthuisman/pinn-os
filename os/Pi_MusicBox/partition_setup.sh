#!/bin/ash

set -x

mkdir -p /tmp/mount

mount $part1 /tmp/mount
sed /tmp/mount/cmdline.txt -i -e "s|root=/dev/[^ ]*|root=${part2}|"
sed /tmp/mount/config/settings.ini -i -e "s|resize_once.*|resize_once = false|"
umount /tmp/mount
sync

mount $part2 /tmp/mount
sed /tmp/mount/etc/fstab -i -e "s|^.* / |${id2}  / |"
sed /tmp/mount/etc/fstab -i -e "s|^.* /boot |${id1}  /boot |"
sed /tmp/mount/etc/fstab -i -e '/^.* swap/s/^/#/'
umount /tmp/mount
sync
