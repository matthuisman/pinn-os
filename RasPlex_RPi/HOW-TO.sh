# Debian 9 VPS 2 vCore 4096 MB Silicon Valley

apt-get update && apt-get install -y unzip bsdtar aria2

# Upload tarballs
sftp matthuisman@frs.sourceforge.net
cd /home/frs/project/pinn-matthuisman/os/RasPlex_RPi
put RaSystem.tar.xz
put RaStorage.tar.xz
exit

# Get total download size in bytes
echo $(($(wc -c < RaSystem.tar.xz) + $(wc -c < RaStorage.tar.xz)))

sha512sum RaSystem.tar.xz
sha512sum RaStorage.tar.xz

# UPDATE os.json
# UPDATE partitions.json