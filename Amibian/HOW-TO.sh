# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar

cd ~ && mkdir mnt
wget http://www.onyxsoft.se/amibian/amibian1.4.1001.zip
unzip amibian*.zip && rm amibian*.zip

fdisk -l amibian*.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,ro,offset=$((16*512)) amibian*.img mnt
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root tarball
mount -o loop,ro,norecovery,offset=$((125056*512)) amibian*.img mnt
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Amibian
put boot.tar.xz
put root.tar.xz
exit

# UPDATE os.json #
