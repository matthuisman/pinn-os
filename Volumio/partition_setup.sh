#!/bin/sh

set -ex

if [ -z "$part1" ] || [ -z "$part2" ] || [ -z "$part3" ]; then
  printf "Error: missing environment variable part1 or part2 or part3\n" 1>&2
  exit 1
fi

mkdir -p /tmp/1
mkdir -p /tmp/3

mount "$part1" /tmp/1
mount "$part3" /tmp/3

sed /tmp/1/cmdline.txt -i -e "s|imgpart=[^ ]*|imgpart=${part2} use_kmsg=no|"
rm /tmp/1/resize-volumio-datapart

##############################

cd /tmp/1
mv volumio.initrd /tmp/3/volumio.gz
cd /tmp/3
gunzip volumio.gz
mkdir mnt
cd mnt
cpio -i -F ../volumio

sed init -i -e "s|/dev/\${BOOTDEV}p1|${part1}|"
sed init -i -e "s|/dev/\${BOOTDEV}p2|${part2}|"
sed init -i -e "s|/dev/\${BOOTDEV}p3|${part3}|"
sed init -i -e "s|/dev/\${BOOTDEV}|/dev/null|" #just in case
sed init -i -e "s|resize-volumio-datapart|i-dont-exist.txt|" #just in case

#Need to add a line to init that fixes the fstab in the squash (Insert around line 223)
#add line "sed /mnt/static/etc/fstab -i -e \"s|^/dev.* /boot |${part1}  /boot |\""  to init line #223

cpio -i -t -F ../volumio | cpio -o -H newc >../volumio_new
cd ..
rm volumio
mv volumio_new volumio
gzip volumio
mv volumio.gz /tmp/1/volumio.initrd
rm -rf /tmp/3/mnt

##############################

cd /tmp
sync
umount /tmp/1
umount /tmp/3
