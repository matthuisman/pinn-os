# Debian 9 VPS 2 vCore 4096 MB

apt-get update && apt-get install -y unzip bsdtar

cd ~ && mkdir mnt
wget http://updates.volumio.org/pi/volumio/2.389/volumio-2.389-2018-03-26-pi.img.zip
unzip volumio-*-pi.img.zip && rm volumio-*-pi.img.zip

fdisk -l volumio-*-pi.img
# Start Sector * Sector Size = Below Offsets

# Boot tarball
mount -o loop,ro,offset=$((1*512)) volumio-*-pi.img mnt
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# Root tarball
mount -o loop,ro,offset=$((125001*512)) volumio-*-pi.img mnt
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Volumio
put boot.tar.xz
put root.tar.xz

#cleanup
rm -r mnt && rm boot.tar.xz && rm root.tar.xz && rm volumio-*-pi.img

# UPDATE os.json "version"