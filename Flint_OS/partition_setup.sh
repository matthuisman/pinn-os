#!/bin/sh

set -ex

if [ -z "$part1" ] || [ -z "$part2" ] || [ -z "$part3" ] || [ -z "$part4" ]; then
  printf "Error: missing environment variable part1 or part2 or part3 or part4\n" 1>&2
  exit 1
fi

mkdir -p /tmp/1 /tmp/2

mount "$part1" /tmp/1
mount "$part2" /tmp/2

sed /tmp/1/cmdline.txt -i -e "s|root=[^ ]*|root=${part2}|"

part1_num=`echo "$part1" | sed -e 's/^.*[^0-9]\([0-9]\+\)$/\1/'`
part2_num=`echo "$part2" | sed -e 's/^.*[^0-9]\([0-9]\+\)$/\1/'`
part3_num=`echo "$part3" | sed -e 's/^.*[^0-9]\([0-9]\+\)$/\1/'`
part4_num=`echo "$part4" | sed -e 's/^.*[^0-9]\([0-9]\+\)$/\1/'`

sed /tmp/2/usr/share/misc/chromeos-common.sh -i -e "s|PARTITION_NUM_EFI_SYSTEM=[^ ]*|PARTITION_NUM_EFI_SYSTEM=${part1_num}|"
sed /tmp/2/usr/share/misc/chromeos-common.sh -i -e "s|PARTITION_NUM_ROOT_A=[^ ]*|PARTITION_NUM_ROOT_A=${part2_num}|"
sed /tmp/2/usr/share/misc/chromeos-common.sh -i -e "s|PARTITION_NUM_OEM=[^ ]*|PARTITION_NUM_OEM=${part3_num}|"
sed /tmp/2/usr/share/misc/chromeos-common.sh -i -e "s|PARTITION_NUM_STATE=[^ ]*|PARTITION_NUM_STATE=${part4_num}|"

umount /tmp/1
umount /tmp/2
