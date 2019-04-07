# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y xz-utils bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4 https://github.com/fedberry/fedberry/releases/download/27.1/fedberry-xfce-27.1.raw.xz
unxz fedberry-xfce-*.raw.xz

fdisk -l fedberry-xfce-*.raw
# Start Sector * Sector Size = Below Offsets

# boot (partition 1) tarball
mount -o loop,ro,offset=$((2048*512)) fedberry-xfce-*.raw mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root (partition 2) tarball
mount -o loop,ro,offset=$((1001472*512)) fedberry-xfce-*.raw mnt
du -h -m --max-depth=0 mnt    #root uncompressed_tarball_size (nominal size += 500MB)
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

sha512sum boot.tar.xz
sha512sum root.tar.xz

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/FedBerry
put boot.tar.xz
put root.tar.xz
exit

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))

# UPDATE os.json