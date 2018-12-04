#!/bin/sh
#supports_backup in PINN

mkdir -p /tmp/1

mount "$part1" /tmp/1

sed /tmp/1/cmdline.txt -i -e "s|console=tty1$|console=tty1 root=${part3}|"

umount /tmp/1
