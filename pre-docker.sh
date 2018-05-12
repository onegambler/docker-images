mkdir -p /mnt/extHD/raspberrypi/configs/{muximux,portainer,radarr,sonarr,jackett}/config
chown -R pi:pi /mnt/extHD/docker

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