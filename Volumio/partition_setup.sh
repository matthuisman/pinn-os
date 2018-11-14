#!/bin/sh

set -ex

if [ -z "$part1" ] || [ -z "$part2" ] || [ -z "$part3" ]; then
  printf "Error: missing environment variable part1 or part2 or part3\n" 1>&2
  exit 1
fi

mkdir -p /tmp/1
mkdir -p /tmp/2

mount "$part1" /tmp/1
mount "$part2" /tmp/2

sed /tmp/1/cmdline.txt -i -e "s|imgpart=[^ ]*|imgpart=${part2}|"
sed /tmp/1/cmdline.txt -i -e "s|loglevel=0$|loglevel=0 use_kmsg=no|"
rm -f /tmp/1/resize-volumio-datapart

rm -f /tmp/1/volumio.initrd
cp /tmp/2/volumio.initrd /tmp/1/volumio.initrd

umount /tmp/1
umount /tmp/2
