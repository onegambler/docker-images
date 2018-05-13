mkdir -p /mnt/extHD/raspberrypi/configs/{muximux,portainer,radarr,sonarr,jackett,mldonkey}
chown -R pi:pi /mnt/extHD/raspberrypi

### Installing nfs
apt-get install nfs-kernel-server portmap nfs-common -y
service nfs-server stop

EXPORT_CONFIG="/mnt/extHD           192.168.1.0/24(rw,nohide,insecure,no_subtree_check,async,all_squash)"
grep -q -F "$EXPORT_CONFIG" /etc/exports || echo "$EXPORT_CONFIG" >> /etc/exports
service nfs-server start


DHCP_CONFIG="interface eth0
static ip_address=192.168.1.64/24
static routers=192.168.1.254
static domain_name_servers=1.1.1.1 1.0.0.1"

grep -q -x "interface eth0" /etc/dhcpcd.conf  || echo "$DHCP_CONFIG" >> /etc/dhcpcd.conf 

#Automount harddrive
export FSTAB_CONFIG="UUID=3b3e573f-f3b5-410c-841a-0ee9949925f7        /mnt/extHD      ext4    defaults          0       0"
grep -q -F "$FSTAB_CONFIG" /etc/fstab || echo "$FSTAB_CONFIG" >> /etc/fstab