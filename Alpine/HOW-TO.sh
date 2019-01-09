# Matt PC

cd ~ && mkdir mnt

su

fdisk -l alpine.img
# Start Sector * Sector Size = Below Offsets

# boot tarball
mount -o loop,ro,offset=$((2048*512)) alpine*.img mnt
du -h -m --max-depth=0 mnt    #boot uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar -cpf ../boot.tar .
cd .. && umount mnt
xz -9 -e boot.tar

# root tarball
mount -o loop,ro,norecovery,offset=$((526336*512)) alpine*.img mnt
du -h -m --max-depth=0 mnt     #root uncompressed_tarball_size
cd mnt
bsdtar --numeric-owner --format gnutar --one-file-system -cpf ../root.tar .
cd .. && umount mnt
xz -9 -e root.tar

# Get total download size in bytes
echo $(($(wc -c < boot.tar.xz) + $(wc -c < root.tar.xz)))

# UPDATE os.json
# UPDATE partitions.json

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/Alpine
put boot.tar.xz
put root.tar.xz
exit