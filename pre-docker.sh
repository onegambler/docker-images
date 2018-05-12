sudo -i
mkdir -p /mnt/extHD/docker/containers/{muximux,observium,portainer,radarr,sonarr,jackett}/config
chown -R pi:pi /mnt/extHD/docker
mkdir -p /mnt/extHD/docker/containers/observium/{config,logs,rrd}
chmod -R 777 observium

### Installing nfs
apt-get install nfs-kernel-server portmap nfs-common
service nfs-server stop
echo "/mnt/extHD           192.168.1.0/24(rw,nohide,insecure,no_subtree_check,async,all_squash)" >> /etc/exports
service nfs-server starts 