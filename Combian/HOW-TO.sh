# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update
apt-get install -y software-properties-common
apt-add-repository non-free
apt-get update

apt-get install unrar bsdtar

cd ~ && mkdir mnt

export googleid=1sNhrr2u6n48vb5xuOe8P9pTayojQoOc_

wget --save-cookies cookies.txt --keep-session-cookies --no-check-certificate \
    'https://docs.google.com/uc?export=download&id='$googleid -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > code.txt

wget -O combian.rar --load-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$googleid'&confirm='$(<code.txt)

unrar x combian.rar
rm cookies.txt code.txt combian.rar

fdisk -l Combian*.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,ro,offset=$((16*512)) Combian*.img mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -T0 -9 -e boot.tar

# root tarball
mount -o loop,ro,norecovery,offset=$((125056*512)) Combian*.img mnt
du -h -m --max-depth=0 mnt     #root uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -T0 -9 -e root.tar

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))

sha512sum boot.tar.xz
sha512sum root.tar.xz

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Combian
put boot.tar.xz
put root.tar.xz
exit

# UPDATE os.json
# UPDATE partitions.json