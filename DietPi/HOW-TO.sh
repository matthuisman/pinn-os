# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y p7zip bsdtar

cd ~ && mkdir mnt
wget http://dietpi.com/downloads/images/DietPi_RPi-ARMv6-Stretch.7z
p7zip -d DietPi_RPi-ARMv6-Stretch.7z

fdisk -l DietPi_v*_RPi-ARMv6-Stretch.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,ro,offset=$((8192*512)) DietPi_v*_RPi-ARMv6-Stretch.img mnt
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root tarball
mount -o loop,ro,offset=$((98304*512)) DietPi_v*_RPi-ARMv6-Stretch.img mnt
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/DietPi
put boot.tar.xz
put root.tar.xz
exit

# UPDATE os.json #
