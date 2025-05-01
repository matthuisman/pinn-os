# WSL2 Ubuntu 24.04
# get version/release date from https://dietpi.com/docs/releases/

sudo apt-get update && sudo apt-get install -y libarchive-tools aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4  https://dietpi.com/downloads/images/DietPi_RPi5-ARMv8-Bookworm.img.xz
unxz DietPi_RPi5-ARMv8-Bookworm.img.xz

fdisk -l DietPi_RPi5-ARMv8-Bookworm.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
sudo mount -o loop,ro,offset=$((2048*512)) DietPi_RPi5-ARMv8-Bookworm.img mnt
sudo du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
sudo bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && sudo umount mnt
sudo xz -T8 -8 boot.tar

# root tarball
sudo mount -o loop,ro,offset=$((264192*512)) DietPi_RPi5-ARMv8-Bookworm.img mnt
sudo du -h -m --max-depth=0 mnt    #root uncompressed_tarball_size
cd mnt
sudo bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && sudo umount mnt
sudo xz -T8 -8 root.tar

echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))   #os.json download_size

sha512sum boot.tar.xz  #boot sha512sum
sha512sum root.tar.xz  #root sha512sum

# Backup old & Upload new tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/DietPi_RPi5

rm boot.tar.xz.bu
rm root.tar.xz.bu

rename boot.tar.xz  boot.tar.xz.bu
rename root.tar.xz  root.tar.xz.bu

put boot.tar.xz
put root.tar.xz

exit

# UPDATE os.json
# UPDATE partitions.json
