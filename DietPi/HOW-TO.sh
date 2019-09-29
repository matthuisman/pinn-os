# Debian 9 VPS 2 vCore 8192 MB Silicon Valley

apt-get update && apt-get install -y p7zip bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4  https://dietpi.com/downloads/images/DietPi_RPi-ARMv6-Buster.7z
p7zip -d DietPi_RPi-ARMv6-Buster.7z

fdisk -l DietPi_v*_RPi-ARMv6-Buster.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,ro,offset=$((8192*512)) DietPi_v*_RPi-ARMv6-Buster.img mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root tarball
mount -o loop,ro,offset=$((540672*512)) DietPi_v*_RPi-ARMv6-Buster.img mnt
du -h -m --max-depth=0 mnt    #root uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))   #os.json download_size

sha512sum boot.tar.xz  #boot sha512sum
sha512sum root.tar.xz  #root sha512sum

# Backup old & Upload new tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/DietPi

rm boot.tar.xz.bu
rm root.tar.xz.bu

rename boot.tar.xz  boot.tar.xz.bu
rename root.tar.xz  root.tar.xz.bu

put boot.tar.xz
put root.tar.xz

exit

# UPDATE os.json
# UPDATE partitions.json