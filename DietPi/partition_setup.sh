#!/bin/sh

set -ex

if [ -z "$part1" ] || [ -z "$part2" ]; then
  printf "Error: missing environment variable part1 or part2\n" 1>&2
  exit 1
fi

mkdir -p /tmp/1 /tmp/2

mount "$part1" /tmp/1
mount "$part2" /tmp/2

sed /tmp/1/cmdline.txt -i -e "s|root=[^ ]*|root=${part2}|"
sed /tmp/1/dietpi/conf/fstab -i -e "s|^.* / |${part2}  / |"
sed /tmp/1/dietpi/conf/fstab -i -e "s|^.* /boot |${part1}  /boot |"
sed /tmp/1/dietpi/boot -i -e "s|FS_Partition$|#FS_Partition|"
sed /tmp/1/dietpi.txt -i -e "s|Swapfile_Size=1|Swapfile_Size=0|"
sed /tmp/1/dietpi.txt -i -e "s|AUTO_Install_Enable=0|AUTO_Install_Enable=1|"

sed /tmp/2/etc/fstab -i -e "s|^.* / |${part2}  / |"
sed /tmp/2/etc/fstab -i -e "s|^.* /boot |${part1}  /boot |"

umount /tmp/1
umount /tmp/2
