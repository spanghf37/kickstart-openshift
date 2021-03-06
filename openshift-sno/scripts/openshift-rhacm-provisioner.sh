#!/bin/bash

## https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.3/html/credentials/credentials#creating-a-credential-for-bare-metal

# Create a non-root user (user-name) and provide that user with sudo privileges by running the following commands:
useradd kni
passwd kni
echo "kni ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/kni
chmod 0440 /etc/sudoers.d/kni

su - kni -c "ssh-keygen -t rsa -f /home/kni/.ssh/id_rsa -N ''"

su - kni

# Install the required packages by running the following command:
sudo dnf install -y libvirt qemu-kvm mkisofs python3-devel jq ipmitool

# Modify the user to add the libvirt group to the newly created user.
sudo usermod --append --groups libvirt kni

# Restart firewalld and enable the http service by entering the following commands
sudo systemctl start firewalld
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --add-port=5000/tcp --zone=libvirt  --permanent
sudo firewall-cmd --add-port=5000/tcp --zone=public   --permanent
sudo firewall-cmd --reload

# Start and enable the libvirtd service by entering the following commands:
sudo systemctl start libvirtd
sudo systemctl enable libvirtd --now

# Create the default storage pool and start it by entering the following commands:
sudo virsh pool-define-as --name default --type dir --target /var/lib/libvirt/images
sudo virsh pool-start default
sudo virsh pool-autostart default

# View the followig examples to configure networking - Provisioning Network (IPv4 address):
export PROV_CONN=enp1s0
sudo nohup bash -c """
    nmcli con down "$PROV_CONN"
    nmcli con delete "$PROV_CONN"
    nmcli connection add ifname provisioning type bridge con-name provisioning
    nmcli con add type bridge-slave ifname "$PROV_CONN" master provisioning
    nmcli connection modify provisioning ipv4.addresses 172.22.0.1/24 ipv4.method manual
    nmcli con down provisioning
    nmcli con up provisioning"""

export PUB_CONN=enp7s0
sudo nohup bash -c """
    nmcli con down "$PUB_CONN"
    nmcli con delete "$PUB_CONN"
    nmcli connection add ifname baremetal type bridge con-name baremetal
    nmcli con add type bridge-slave ifname "$PUB_CONN" master baremetal
    nmcli connection modify baremetal ipv4.addresses 192.168.122.52/24 ipv4.dns 192.168.122.1 ipv4.gateway 192.168.122.1 ipv4.method manual
    nmcli con down baremetal
    nmcli con up baremetal"""

# Reconnect to the provisioner node by using SSH (if required).

# Verify the connection bridges have been correctly created by running the following command (provisioning and baremetal):
nmcli con show

# Copy pull-secret in a file "pull-secret" inside "/home/kni" on the provisioner host.


sudo dnf update -y
sudo dnf install -y python3 python3-devel libvirt-devel gcc git OpenIPMI ipmitool jq
sudo dnf groupinstall -y "Development Tools"

sudo dnf install -y libvirt-devel
pip3 install --upgrade pip
pip3 install setuptools_rust
pip3 install wheel
pip3 install libvirt
pip3 install virtualbmc


ssh-copy-id USERNAME_LIBVIRT_HOST@192.168.122.1
vbmc add --port 6270 --username USERID --password PASSW0RD --libvirt-uri=qemu+ssh://USERNAME_LIBVIRT_HOST@192.168.122.1/system openshift-sno-dev
vbmc start openshift-sno-dev
vbmc list

ipmitool -I lanplus -H 192.168.122.52 -p 6270 -U USERID -P PASSW0RD chassis power status

