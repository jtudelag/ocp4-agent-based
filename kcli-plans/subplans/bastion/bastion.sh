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

sudo dnf install -y dnsmasq bind-utils podman wget httpd-tools

cat <<EOF > ocp4.conf
host-record=master0.ocp4.abi.com,192.168.70.2
host-record=bastion.ocp4.abi.com,192.168.70.5
host-record=registry.ocp4.abi.com,192.168.70.5

#listen-address=192.168.70.5
interface=eth0

server=1.1.1.1
server=8.8.8.8
EOF

sudo cp ocp4.conf /etc/dnsmasq.d/ocp4.conf

echo -e "[Unit]\nAfter=network-online.target" > override.conf
sudo mkdir -p /etc/systemd/system/dnsmasq.service.d/
sudo mv override.conf /etc/systemd/system/dnsmasq.service.d/

sudo systemctl enable --now dnsmasq

mkdir -p ~/.docker/auth/
sudo htpasswd -Bbn jorge mypass > ~/.docker/auth/auth
sudo cp auth ~/.docker/auth/auth

sudo mkdir /var/lib/registry
podman container run -dt -p 5000:5000 \
                     --name registry2 \
                     --volume "$HOME/.docker/auth:/auth":Z \
                     -e "REGISTRY_AUTH=htpasswd" \
                     -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
                     -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/auth \
                     --volume registry:/var/lib/registry:Z docker.io/library/registry:2

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/oc-mirror.tar.gz