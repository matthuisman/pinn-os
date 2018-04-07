# Debian 9 VPS 2 vCore 4096 MB US SERVER

apt-get update && apt-get install -y unzip bsdtar

cd ~ && mkdir mnt
wget http://updates.volumio.org/pi/volumio/2.389/volumio-2.389-2018-03-26-pi.img.zip
unzip volumio-*-pi.img.zip && rm volumio-*-pi.img.zip

fdisk -l volumio-*-pi.img
# Start Sector * Sector Size = Below Offsets

# Boot tarball
mount -o loop,rw,offset=$((1*512)) volumio-*-pi.img mnt
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# volumio tarball
mount -o loop,rw,offset=$((125001*512)) volumio-*-pi.img mnt
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

#cleanup
rm -r mnt && rm boot.tar.xz && rm volumio.tar.xz && rm volumio-*-pi.img

# UPDATE os.json "version"