# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4 https://github.com/home-assistant/hassos/releases/download/1.13/hassos_rpi3-1.13.img.gz
gzip -d hassos_rpi3-*.img.gz

fdisk -l hassos_rpi3-*.img
# Start Sector * Sector Size = Below Offsets

# hassos-boot tarball
mount -o loop,ro,offset=$((2048*512)) hassos_rpi3-*.img mnt
du -h -m --max-depth=0 mnt    #hassos-boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../hassos-boot.tar .
cd .. && umount mnt
xz -9 -e hassos-boot.tar

# hassos-kernel tarball
mount -o loop,ro,norecovery,offset=$((67584*512)) hassos_rpi3-*.img mnt
du -h -m --max-depth=0 mnt     #hassos-kernel uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../hassos-kernel.tar .
cd .. && umount mnt
xz -9 -e hassos-kernel.tar

# hassos-data tarball
mount -o loop,ro,norecovery,offset=$((1427456*512)) hassos_rpi3-*.img mnt
du -h -m --max-depth=0 mnt     #hassos-data uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../hassos-data.tar .
cd .. && umount mnt
xz -9 -e hassos-data.tar

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/hassio_RPi3
put hassos-boot.tar.xz
put hassos-kernel.tar.xz
put hassos-data.tar.xz
exit

# Get total download size in bytes
echo $(($(wc -c < hassos-boot.tar.xz) + $(wc -c < hassos-kernel.tar.xz) + $(wc -c < hassos-data.tar.xz)))

# UPDATE os.json
# UPDATE partitions.json