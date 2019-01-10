# Matt PC

## BOOT ALPINE with network
## Login: root

setup-interfaces
/etc/init.d/networking restart

setup-ntp
[ENTER]

setup-apkrepos 
[1]

mkdir /stage
mount /dev/mmcblk0p2 /stage
setup-disk /stage

cd /stage

vi etc/fstab.txt # i to edit
# Change start of first line to /dev/mmcblk0p2 (instead of uuid)
# Add new line below
# /dev/mmcblk0p1 /boot vfat defaults 0 0
# Save: ESC > :wq

rm -r boot
mkdir -p var/cache/apk
ln -s /var/cache/apk etc/apk/cache

vi etc/apk/repositories  # i to edit
#Remove first line for /media/mmcblkop1/apks
# Save: ESC > :wq

mount -o remount,rw /media/mmcblk0p1

cd /media/mmcblk0p1
vi cmdline.txt # i to edit
# Add root=/dev/mmcblk0p2 to cmdline.txt
# Save: ESC > :wq

mv boot/* .
mv cache/* /stage/var/cache/apk
rm -r boot cache apks modloop-rpi*

vi config.txt # i to edit
# Remove boot/ from all the kernel and initramfs paths eg. boot/vmlinux-rpi > vmlinux-rpi
# Save: ESC > :wq

reboot

apk add e2fsprogs
rc-update add swclock boot
rc-update del hwclock boot

poweroff


cd ~ && mkdir mnt

su

fdisk -l alpine.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,ro,offset=$((2048*512)) alpine*.img mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root tarball
mount -o loop,ro,norecovery,offset=$((526336*512)) alpine*.img mnt
du -h -m --max-depth=0 mnt     #root uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))

# UPDATE os.json
# UPDATE partitions.json

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Alpine
put boot.tar.xz
put root.tar.xz
exit