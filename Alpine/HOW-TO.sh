# Matt PC

## BOOT ALPINE
## Login: root

setup-interfaces #eth0 dhcp done no
/etc/init.d/networking start

apk add chrony
/etc/init.d/chronyd start

rm /etc/apk/repositories
setup-apkrepos #1
setup-apkcache #/var/cache/apk

apk update
apk upgrade

apk add e2fsprogs tzdata kbd-bkeymaps wireless-tools wpa_supplicant openssh

rc-update add swclock boot
rc-update del hwclock boot

lbu commit -d mmcblk0p1


mkfs.ext4 /dev/mmcblk0p2 #y
e2fsck /dev/mmcblk0p2

mkdir /stage
mount /dev/mmcblk0p2 /stage

setup-disk -o /media/mmcblk0p1/localhost.apk* /stage

rm -r /stage/boot /stage/etc/network/interfaces /stage/etc/apk/repositories

vi /stage/etc/fstab  # i to edit
# Change start of first line to /dev/mmcblk0p2 (instead of uuid)
# Add 2x below lines
/dev/mmcblk0p1 /media/boot vfat defaults 0 0
/media/boot /boot none defaults,bind 0 0
# Save: ESC > :wq

mount -o remount,rw /media/mmcblk0p1

cd /media/mmcblk0p1
vi cmdline.txt # i to edit
# Add 
root=/dev/mmcblk0p2 
#to cmdline.txt
# Save: ESC > :wq

vi config.txt # i to edit
# Remove boot/ from all the kernel and initramfs paths eg. boot/vmlinux-rpi > vmlinux-rpi
# Save: ESC > :wq

mv boot/* .
rm -r boot apks modloop* localhost.apk* "System Volume Information"

poweroff




## PC ##
cd ~ && mkdir mnt

su

fdisk -l #find sdX of SD

# boot tarball
mount /dev/sdd1 mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root tarball
mount /dev/sdd2 mnt
du -h -m --max-depth=0 mnt     #root uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))

sha512sum boot.tar.xz
sha512sum root.tar.xz

# UPDATE os.json
# UPDATE partitions.json

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Alpine
put boot.tar.xz
put root.tar.xz
exit