# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y xz-utils bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4 http://mirror.centos.org/altarch/7/isos/armhfp/CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-1804-sda.raw.xz
unxz CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-*-sda.raw.xz

fdisk -l CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-*-sda.raw
# Start Sector * Sector Size = Below Offsets

# boot (partition 1) tarball
mount -o loop,ro,offset=$((2048*512)) CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-*-sda.raw mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root (partition 3) tarball
mount -o loop,ro,offset=$((2369536*512)) CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-*-sda.raw mnt
du -h -m --max-depth=0 mnt    #root uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/CentOS_RPi3
put boot.tar.xz
put root.tar.xz
exit

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))

# UPDATE os.json
# UPDATE partitions.json