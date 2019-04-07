# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4 https://bit.ly/gladys-3-8-0-rev2-mirror-fr2
unzip gladys*.img.zip && rm gladys*.img.zip

fdisk -l gladys*.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,ro,offset=$((8192*512)) gladys*.img mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root tarball
mount -o loop,ro,norecovery,offset=$((94208*512)) gladys*.img mnt
du -h -m --max-depth=0 mnt     #root uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

sha512sum boot.tar.xz
sha512sum root.tar.xz

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Gladys
put boot.tar.xz
put root.tar.xz
exit

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))

# UPDATE os.json
# UPDATE partitions.json