# Debian 9 VPS 4 vCore 8192 MB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4 http://updates.volumio.org/pi/volumio/2.779/volumio-2.779-2020-06-08-pi.img.zip
unzip volumio-*-pi.img.zip && rm volumio-*-pi.img.zip

fdisk -l volumio-*-pi.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,rw,offset=$((1*512)) volumio-*-pi.img mnt

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
mount -o loop,rw,offset=$((125001*512)) volumio-*-pi.img mnt
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

rename boot.tar.xz     boot.tar.xz.bu
rename volumio.tar.xz  volumio.tar.xz.bu

put boot.tar.xz
put volumio.tar.xz

exit

# UPDATE os.json
# UPDATE partitions.json