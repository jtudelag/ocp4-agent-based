#!/bin/bash

#address=/apps.sno-cluster.ocp4.abi.com/192.168.70.5
#address=/api.sno-cluster.ocp4.abi.com/192.168.70.5
#address=/api-int.sno-cluster.ocp4.abi.com/192.168.70.5

echo "root" | passwd --stdin root
sudo nmcli con mod 'cloud-init eth0' ipv4.dns "1.1.1.1,8.8.8.8"
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo rm /etc/resolv.conf
sudo systemctl restart NetworkManager
sleep 5
sudo dnf install -y dnsmasq bind-utils
cat <<EOF > ocp4.conf
host-record=master0.ocp4.abi.com,192.168.70.2
host-record=bastion.ocp4.abi.com,192.168.70.5

listen-address=192.168.70.5

server=1.1.1.1
server=8.8.8.8
EOF

sudo cp ocp4.conf /etc/dnsmasq.d/ocp4.conf
sudo systemctl enable --now dnsmasq