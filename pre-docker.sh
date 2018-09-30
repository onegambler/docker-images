### Install docker
#curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh

sudo apt-get update && sudo apt-get -y upgrade
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
echo "deb [arch=armhf] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
     $(lsb_release -cs) stable" |     sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update && sudo apt-get upgrade
sudo apt install -y docker-ce python python-pip
pip install docker-compose

# Enable docker API
sudo sed -i '/ExecStart/s/$/ -H tcp:\/\/0.0.0.0:/' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker.service

sudo groupadd docker
sudo usermod -aG docker $USER

# Setting up aliases
ALIASES="alias ll='ls -altr'
dbash() { docker exec -it $(docker ps -aqf "name=$1") bash; }
alias dps='docker ps'
alias dprune='docker system prune'"

grep -q -F "$ALIASES" /home/pi/.bash_aliases || echo "$ALIASES" > /home/pi/.bash_aliases

# Automount harddrive
sudo mount -t ext4 UUID=3b3e573f-f3b5-410c-841a-0ee9949925f7 /mnt/extHD
export FSTAB_CONFIG="UUID=3b3e573f-f3b5-410c-841a-0ee9949925f7        /mnt/extHD      ext4    defaults          0       0"
grep -q -F "$FSTAB_CONFIG" /etc/fstab || echo "$FSTAB_CONFIG" | sudo tee --append /etc/fstab > /dev/null

sudo mkdir -p /mnt/extHD/raspberrypi/configs/{muximux,portainer,radarr,sonarr,jackett,mldonkey}
sudo chown -R pi:pi /mnt/extHD/raspberrypi

### Installing nfs
sudo apt-get install nfs-kernel-server portmap nfs-common -y
sudo service nfs-server stop

EXPORT_CONFIG="/mnt/extHD           192.168.1.0/24(rw,nohide,insecure,no_subtree_check,async,all_squash)"
grep -q -F "$EXPORT_CONFIG" /etc/exports || echo "$EXPORT_CONFIG" | sudo tee --append /etc/exports > /dev/null
sudo service nfs-server start


DHCP_CONFIG="interface eth0
static ip_address=192.168.1.64/24
static routers=192.168.1.254
static domain_name_servers=1.1.1.1 1.0.0.1"

grep -q -x "interface eth0" /etc/dhcpcd.conf  || echo "$DHCP_CONFIG" | sudo tee --append  /etc/dhcpcd.conf > /dev/null

### Install bluetooth dongle
sudo sed -i '/ExecStart/s/$/ --noplugin=sap/' /etc/systemd/system/bluetooth.target.wants/bluetooth.service
sudo systemctl daemon-reload
sudo service bluetooth restart