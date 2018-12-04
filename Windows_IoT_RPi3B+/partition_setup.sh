#!/bin/sh
#  Copyright(c) Microsoft Corp. All rights reserved.

#  The MIT License(MIT)
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files(the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions :
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

IMAGE="/tmp/scratch/IOT Core RPi.ISO"
FFUARCHIVE="/tmp/iso/*.msi"
FAILURE="Your installation has failed or has been canceled. You must reboot into recovery mode (press the Shift key on boot) to restart the installation."

DEBUG=0
if [ $DEBUG -eq 1 ] ; then
#  URL="http://herricks-dev2/Windows10_InsiderPreview_IoTCore_RPi_ARM32_en-us_14322.iso"
#  URL="http://herricks-dev2/flash.7z"
#  URL="http://herricks-dev2/10586.0.151029-1700.TH2_Release_IOTCoreRPi_armFRE.ISO"
#  URL="http://herricks-dev2/14332.1001.160425-1700.RS1_IOT_CORE_X64FRE_IOTCORE_RPI.iso"
#  URL="http://herricks-dev2/14342.1000.160506-1708.RS1_RELEASE_X64FRE_IOTCORE_RPI.ISO"
  URL="http://anphel-th-uap/17115.1.180302-1642.rs4_release_amd64fre_IOTCORE_RPi.iso"
  if echo $URL | grep -Eqi '.*\.7z'; then
	  FFUARCHIVE="/tmp/scratch/flash.7z"
	  IMAGE=$FFUARCHIVE
	fi
fi

if [ -z "$part1" ] || [ -z "$part2" ] || [ -z "$part3" ] || [ -z "$part4" ] || [ -z "$part5" ] ; then
    printf "Error: missing partition names\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

EfiPart="$part1"
MainOSPart="$part2"
ScratchPart="$part3"
MbrMetaPart="$part4"
DataPart="$part5"

EfiPartnum=`expr $EfiPart : '.*[^0-9]\([0-9][0-9]*\)$'`
MainOSPartnum=`expr $MainOSPart : '.*[^0-9]\([0-9][0-9]*\)$'`
DataPartnum=`expr $DataPart : '.*[^0-9]\([0-9][0-9]*\)$'`
MbrMetaPartnum=`expr $MbrMetaPart : '.*[^0-9]\([0-9][0-9]*\)$'`

if [ "$EfiPart" != "/dev/mmcblk0p2" ] || [ "$MainOSPart" != "/dev/mmcblk0p3" ] ; then
    printf "$part1 $part2 $part3 $part4 $part5 Error: NOOBS version is incompatible with Windows 10 IoT core. Please download the newest version of NOOBS from https://www.raspberrypi.org/downloads/\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# Make mount points and mount scratch partition
mkdir -p /tmp/iso
mkdir -p /tmp/mainos
mkdir -p /tmp/scratch

mount $ScratchPart /tmp/scratch
if [ "$?" != "0" ] ; then
    printf "Error mounting scratch partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

printf "EfiPart=$EfiPart;MainOSPart=$MainOSPart;ScratchPart=$ScratchPart;DataPart=$DataPart;MbrMetaPart=$MbrMetaPart;" > /tmp/scratch/part2.log

# Copy files from existing EFIESP partition
mkdir -p /tmp/scratch/EFIESP
cp /mnt2/* /tmp/scratch/EFIESP

if [ $DEBUG -eq 1 ] ; then
  echo $URL > /tmp/scratch/isodlurl;
else
  # Check for EULA acceptance and other tests
  cd /tmp/scratch/installtool-1.0

  if [ ! -r "./InstallationPrecheck" ] ; then
      printf "Cannot find precheck tool\r\n" 1>&2
      printf "$FAILURE" 1>&2
      exit 1
  fi

  ./InstallationPrecheck &> /tmp/scratch/installtool-output.log
  PRECHECK="$?"
  if [ $PRECHECK != "0" ] ; then
      printf "$FAILURE" 1>&2
      exit $PRECHECK
  fi

  # check for requested Download
  if [ ! -f /tmp/scratch/isodlurl ] ; then
      printf "Cannot find DL URL file info\r\n" 1>&2
      printf "$FAILURE" 1>&2
      exit 1
  fi

  # Clean up after speed check for space saving
  if [ -f /tmp/scratch/output ] ; then
  	rm /tmp/scratch/output
  fi
fi

if [ ! -f "$IMAGE" ] ; then
  # download ISO image and mount it
  #URL=`cat /tmp/scratch/isodlurl`
  URL='http://downloads.sourceforge.net/project/pinn-matthuisman/os/windows10iot/Windows10_InsiderPreview_IoTCore_RPi3B_en-us_17661.iso'
  printf "downloading from $URL"
  wget --tries=inf --user-agent="NOOBS" --referer="http://www.windowsondevices.com/noobs" -o "/tmp/scratch/wgetoutput1.log" --output-document="$IMAGE" "$URL"
  if [ "$?" != "0" ] ; then
      printf "Error downloading ISO to SD card\r\n" 1>&2
      printf "$FAILURE" 1>&2
      exit 1
  fi
  # Save a bit of space by truncating log
  tail /tmp/scratch/wgetoutput1.log > /tmp/scratch/wgetoutput.log
  rm /tmp/scratch/wgetoutput1.log
fi

if [ ! -r "$IMAGE" ] ; then
    printf "Error: missing OS image $IMAGE\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

if echo $IMAGE | grep -Eqi '.*\.iso'; then
  mount "$IMAGE" /tmp/iso
  if [ "$?" != "0" ] ; then
      printf "Error mounting ISO image\r\n" 1>&2
      printf "$FAILURE" 1>&2
      exit 1
  fi
fi

cd /tmp/scratch
#unmount EFIESP
umount /mnt2

# does msi contain *.ffu or fil*  ?
# note: this can be assumed fil* after 14279 or later is RTM
filecountFFU=`7z l "$FFUARCHIVE" *.ffu | grep -o -E "[0-9]+ files" | grep -o -E "[0-9]+"`
filecountFil=`7z l "$FFUARCHIVE" fil* | grep -o -E "[0-9]+ files" | grep -o -E "[0-9]+"`
if [ $filecountFFU -gt $filecountFil ] ; then
 FFUregEx="*.ffu"
else
  FFUregEx="fil*"
fi

# Extract the MBR record, hash table and catalog files from the FFU file
7z e -so "$FFUARCHIVE" "$FFUregEx" 2> /tmp/scratch/7z.pass1.log | /tmp/scratch/ffu -stdin 0 1 ffu_mbr.img > /tmp/scratch/ffu_mbr.log
if [ "$?" != "0" ] ; then
    printf "Error retrieving MBR record\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# Check the validity of the hash table file against the catalog
/tmp/scratch/catcheck /tmp/scratch/catalog /tmp/scratch/hash > catcheck.log
if [ "$?" != "0" ] ; then
    printf "Error checking FFU signature\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# get the MBR record from the SD card, parse the partition offsets and sizes
# from both the SD card and the FFU file MBR records
sfdisk -uS -d /dev/mmcblk0 > /tmp/scratch/sd_mbr.txt

# The line count in ffu_table.txt should equal the number of partitions in the FFU
# FFU files with 6 partitions are assumed to have the CrashDump partition, and 5 partitions otherwise
# Adjust slot numbers accordingly
NUMBERFFUPARTITIONS=$(wc -l < /tmp/scratch/ffu_table.txt)
if [ $NUMBERFFUPARTITIONS -eq 6 ] ; then
    ffuDataParam=`grep "slot6[^0-9]"    /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1 \2/g'`
    ffuMbrMetaParam=`grep "slot5[^0-9]" /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1 \2/g'`
    ffuDataStart=`grep "slot6[^0-9]"    /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
    ffuMbrMetaStart=`grep "slot5[^0-9]" /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
else
    ffuDataParam=`grep "slot5[^0-9]"    /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1 \2/g'`
    ffuMbrMetaParam=`grep "slot3[^0-9]" /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1 \2/g'`
    ffuDataStart=`grep "slot5[^0-9]"    /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
    ffuMbrMetaStart=`grep "slot3[^0-9]" /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
fi
ffuEfiParam=`grep "slot1[^0-9]"         /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1 \2/g'`
ffuMainOSParam=`grep "slot2[^0-9]"      /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1 \2/g'`
ffuEfiStart=`grep "slot1[^0-9]"         /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
ffuMainOSStart=`grep "slot2[^0-9]"      /tmp/scratch/ffu_table.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`

printf "ffu EFIESP parameters $ffuEfiParam\r\n"
printf "ffu MainOS parameters $ffuMainOSParam\r\n"
printf "ffu Data parameters   $ffuDataParam\r\n"
printf "ffu MbrMeta parameters   $ffuMbrMetaParam\r\n"

efiParam=`grep "$EfiPart[^0-9]" sd_mbr.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
mainOsParam=`grep "$MainOSPart[^0-9]" sd_mbr.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
dataParam=`grep "$DataPart[^0-9]" sd_mbr.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
mbrMetaParam=`grep "$MbrMetaPart[^0-9]" sd_mbr.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
recoveryParam=`grep "/dev/mmcblk0p1[^0-9]" sd_mbr.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
scratchParam=`grep "$ScratchPart[^0-9]" sd_mbr.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
settingsParam=`grep "/dev/mmcblk0p5[^0-9]" sd_mbr.txt | sed 's/^.*start= *\([0-9][0-9]*\).*size= *\([0-9][0-9]*\).*$/\1/g'`
printf "SD RECOVERY parameters  $recoveryParam\r\n"
printf "SD EFIESP parameters  $efiParam\r\n"
printf "SD MainOS parameters  $mainOsParam\r\n"
printf "SD settings parameters  $settingsParam\r\n"
printf "SD scratch parameters  $scratchParam\r\n"
printf "SD Data parameters    $dataParam\r\n"
printf "SD MbrMeta parameters $mbrMetaParam\r\n"

# correct the MBR_META partition type
sfdisk --change-id /dev/mmcblk0 $MbrMetaPartnum 70

# update the disk signature
/tmp/scratch/diskid /dev/mmcblk0 > diskid.log
if [ "$?" != "0" ] ; then
    printf "Error setting disk id on SD card\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# write the partitions out to the SD card
7z e -so "$FFUARCHIVE" "$FFUregEx" | /tmp/scratch/ffu -stdin $ffuEfiParam $EfiPart $ffuMainOSParam $MainOSPart $ffuMbrMetaParam $MbrMetaPart $ffuDataParam $DataPart > /tmp/scratch/ffu_image.log
if [ "$?" != "0" ] ; then
    printf "Error writing image to SD card\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# Resize data partition to expand to availible space
ntfsfix $DataPart > ntfsfixdata.log
ntfsresize -f $DataPart > ntfsresizedata.log <<-EOF
yes
EOF

# sync the file system, remount the EFIESP partition
sync
mount $EfiPart /mnt2
if [ "$?" != "0" ] ; then
    printf "Error mounting EFIESP partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# backup the existing bcd file then patch the original
cp /mnt2/EFI/Microsoft/boot/bcd /tmp/scratch/bcd.orig

/tmp/scratch/bcdpatch /tmp/scratch/ffu_mbr.img 1 2 /dev/mmcblk0 $EfiPartnum $MainOSPartnum /mnt2/EFI/Microsoft/boot/bcd > bcdpatch.log
if [ "$?" != "0" ] ; then
    printf "Error patching bcd file\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# check the MainOS partition for errors and mount it
ntfsfix -bd $MainOSPart > ntfsfix.log
if [ "$?" != "0" ] ; then
    printf "Error cleaning MainOS partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

ntfs-3g $MainOSPart /tmp/mainos
if [ "$?" != "0" ] ; then
    printf "Error mounting MainOS partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# determine capitalization of System32 directory (changed to lowercase in latest images)
systemHivePath="/tmp/mainos/Windows/System32/config/SYSTEM"
if [ ! -e "$systemHivePath" ] ; then
	systemHivePath="/tmp/mainos/Windows/system32/config/SYSTEM"
fi

# patch the registry to update the mounted volumes
/tmp/scratch/regpatch /tmp/scratch/ffu_mbr.img $ffuEfiStart /dev/mmcblk0 $efiParam $systemHivePath > regpatch.log
if [ "$?" != "0" ] ; then
    printf "Error patching 'Efi' mounted volume data\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

/tmp/scratch/regpatch /tmp/scratch/ffu_mbr.img $ffuMainOSStart /dev/mmcblk0 $mainOsParam $systemHivePath >> regpatch.log
if [ "$?" != "0" ] ; then
    printf "Error patching 'MainOS' mounted volume data\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

/tmp/scratch/regpatch /tmp/scratch/ffu_mbr.img $ffuDataStart /dev/mmcblk0 $dataParam $systemHivePath >> regpatch.log
if [ "$?" != "0" ] ; then
    printf "Error patching 'Data' mounted volume data\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# backup and patch the MBR Meta partition
cp $MbrMetaPart metadata.orig

/tmp/scratch/metapatch -patch $ffuEfiStart $efiParam $MbrMetaPart > metapatch.log
if [ "$?" != "0" ] ; then
    printf "Error patching meta-data partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

/tmp/scratch/metapatch -patch $ffuMainOSStart $mainOsParam $MbrMetaPart >> metapatch.log
if [ "$?" != "0" ] ; then
    printf "Error patching meta-data partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

/tmp/scratch/metapatch -patch $ffuDataStart $dataParam $MbrMetaPart >> metapatch.log
if [ "$?" != "0" ] ; then
    printf "Error patching meta-data partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

/tmp/scratch/metapatch -patch $ffuMbrMetaStart $mbrMetaParam $MbrMetaPart >> metapatch.log
if [ "$?" != "0" ] ; then
    printf "Error patching meta-data partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# add any extra partitions
(grep '/dev/mmcblk0.*start=.*Id=' sd_mbr.txt | sed 's/^.*start= *\([0-9][0-9]*\).*Id= *\([0-9a-f][0-9a-f]*\).*$/\2 \1/g') | while read line; do /tmp/scratch/metapatch -add partition $line $MbrMetaPart; done > extraparts.log
if [ "$?" != "0" ] ; then
    printf "Error patching meta-data partition\r\n" 1>&2
    printf "$FAILURE" 1>&2
    exit 1
fi

# unmount the ISO, MainOS and scratch partitions
cd /mnt

umount /tmp/mainos
umount /tmp/iso
umount /tmp/scratch
