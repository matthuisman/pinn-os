# Debian 9 VPS 4 vCore 8192 MB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4 http://updates.volumio.org/pi/volumio/2.522/volumio-2.522-2018-12-30-pi.img.zip
unzip volumio-*-pi.img.zip && rm volumio-*-pi.img.zip

fdisk -l volumio-*-pi.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,rw,offset=$((1*512)) volumio-*-pi.img mnt

## Make new initrd
cp mnt/volumio.initrd volumio.initrd

mkdir init && cd init
zcat ../volumio.initrd | cpio --extract
rm init
wget https://raw.githubusercontent.com/matthuisman/pinn-os/master/Volumio/init
chmod +x init
find . 2>/dev/null | cpio --quiet --dereference -o -H newc | gzip -9 > ../volumio.initrd
######

cd ../mnt
rm volumio.initrd
cp ../volumio.initrd .

bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd ..
rm -r init
du -h -m --max-depth=0 mnt  #boot uncompressed_tarball_size
umount mnt
xz -9 -e boot.tar

# volumio tarball
mount -o loop,rw,offset=$((125001*512)) volumio-*-pi.img mnt
cd mnt
cp ../volumio.initrd .
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../volumio.tar .
cd ..
du -h -m --max-depth=0 mnt    #volumio uncompressed_tarball_size
umount mnt
xz -9 -e volumio.tar

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < volumio.tar.xz)))

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Volumio
put boot.tar.xz
put volumio.tar.xz
exit

# UPDATE os.json
# UPDATE partitions.json