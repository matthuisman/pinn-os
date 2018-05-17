# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4 http://updates.volumio.org/pi/volumio/2.389/volumio-2.389-2018-03-26-pi.img.zip
unzip volumio-*-pi.img.zip && rm volumio-*-pi.img.zip

fdisk -l volumio-*-pi.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,rw,offset=$((1*512)) volumio-*-pi.img mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# volumio tarball
mount -o loop,rw,offset=$((125001*512)) volumio-*-pi.img mnt
du -h -m --max-depth=0 mnt    #volumio uncompressed_tarball_size
cd mnt
wget https://sourceforge.net/projects/pinn-matthuisman/files/os/Volumio/volumio.initrd
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../volumio.tar .
cd .. && umount mnt
xz -9 -e volumio.tar

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Volumio
put boot.tar.xz
put volumio.tar.xz
exit

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < volumio.tar.xz)))

# UPDATE os.json
# UPDATE partitions.json