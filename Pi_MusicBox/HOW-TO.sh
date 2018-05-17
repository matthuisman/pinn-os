# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar aria2

cd ~ && mkdir mnt
aria2c -x 4 -s 4 https://github.com/pimusicbox/pimusicbox/releases/download/v0.7.0RC6/musicbox_v0.7.0RC6.zip
unzip musicbox_*.zip

fdisk -l musicbox_*.img
# Start Sector * Sector Size = Below Offsets

# pmb_boot (partition 1) tarball
mount -o loop,ro,offset=$((8192*512)) musicbox_*.img mnt
du -h -m --max-depth=0 mnt    #pmb_boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../pmb_boot.tar .
cd .. && umount mnt
xz -9 -e pmb_boot.tar

# pmb_root (partition 2) tarball
mount -o loop,ro,offset=$((122880*512)) musicbox_*.img mnt
du -h -m --max-depth=0 mnt     #pmb_root uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../pmb_root.tar .
cd .. && umount mnt
xz -9 -e pmb_root.tar

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Pi_MusicBox
put pmb_boot.tar.xz
put pmb_root.tar.xz
exit

# Get total download size in bytes
echo $(($(wc -c < pmb_boot.tar.xz) + $(wc -c < pmb_root.tar.xz)))

# UPDATE os.json
# UPDATE partitions.json