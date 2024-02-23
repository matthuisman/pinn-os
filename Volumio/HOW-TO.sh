# 4 GB Memory / 2 Intel vCPUs / 120 GB Disk / SFO3 - Debian 10 x64

apt-get update && apt-get install -y unzip bsdtar aria2 xz-utils

cd ~ && mkdir mnt
aria2c -x 4 -s 4 https://updates.volumio.org/pi/volumio/3.616/Volumio-3.616-2024-02-13-pi.zip
unzip Volumio-*-pi.zip && rm Volumio-*-pi.zip

fdisk -l Volumio-*-pi.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,rw,offset=$((1*512)) Volumio-*-pi.img mnt

## Make new initrd
mkdir build && cd build
zcat ../mnt/volumio.initrd | cpio --extract
rm -f ../mnt/volumio.initrd
rm init
wget https://raw.githubusercontent.com/matthuisman/pinn-os/master/Volumio/init
chmod +x init
find . 2>/dev/null | cpio --quiet -o -H newc | gzip -9 > ../mnt/volumio.initrd
######

cd ../mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd ..
du -h -m --max-depth=0 mnt  #boot uncompressed_tarball_size
umount mnt
xz -T0 -9 -e boot.tar

# volumio tarball
mount -o loop,rw,offset=$((188416*512)) Volumio-*-pi.img mnt
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../volumio.tar .
cd ..
du -h -m --max-depth=0 mnt    #volumio uncompressed_tarball_size
umount mnt
xz -T0 -9 -e volumio.tar

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < volumio.tar.xz)))   #os.json download_size

sha512sum boot.tar.xz     #boot sha512sum
sha512sum volumio.tar.xz  #volumio sha512sum

# Backup old & Upload new tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Volumio

rm boot.tar.xz.bu
rm volumio.tar.xz.bu

rename boot.tar.xz boot.tar.xz.bu
rename volumio.tar.xz volumio.tar.xz.bu

put boot.tar.xz
put volumio.tar.xz

exit

# UPDATE os.json
# UPDATE partitions.json
