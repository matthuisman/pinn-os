# Debian 10 VPS 4 vCore 8GB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar

cd ~ && mkdir mnt
wget https://github.com/RasPlex/RasPlex/releases/download/1.8.0b/RasPlex-1.8.0b.148-573b6d73-RPi.arm.img.gz
gzip -d RasPlex-*.img.gz

fdisk -l RasPlex-*.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,ro,offset=$((8192*512)) -t vfat RasPlex-*.img mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -T0 -9 -e boot.tar

# Upload tarball
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/RasPlex_RPi
put boot.tar.xz
exit

# Get total download size in bytes
echo $(wc -c < boot.tar.xz)

sha512sum boot.tar.xz

# UPDATE os.json
# UPDATE partitions.json
