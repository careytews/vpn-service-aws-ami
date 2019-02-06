#!/bin/sh

echo '----- Config script starting --------------------------------------'

apt update
export DEBIAN_FRONTEND=noninteractive
apt-get-y -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" upgrade

apt install -y python
apt install -y python-pip
apt install -y luarocks
apt install -y gcc
apt install -y liblua5.2-dev
apt install -y findutils
apt install -y net-tools
apt install -y iptables
luarocks install uuid
apt install -y python python-zmq python-requests python-httplib2

apt install -y openvpn
apt install -y awscli
apt install -y wget

wget -q -O- http://download.trustnetworks.com/trust-networks.asc | \
    apt-key add -
echo 'deb http://download.trustnetworks.com/ubuntu artful main' >> \
     /etc/apt/sources.list
apt update

apt install -y cyberprobe

cat <<EOF > /lib/systemd/system/tailoring.service

[Unit]
Description=Local tailor
Before=openvpn@server.service cyberprobe.service cyberprobe-sync.service
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/tailor
Type=oneshot

[Install]
WantedBy=multi-user.target

EOF

cat <<EOF > /lib/systemd/system/cyberprobe-sync.service

[Unit]
Description=OpenVPN to cyberprobe sync service

[Service]
PIDFile=/var/run/cyberprobe.pid
ExecStart=/usr/local/bin/cyberprobe-sync

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload

systemctl enable cyberprobe
systemctl enable cyberprobe-sync
systemctl enable openvpn@server
systemctl enable tailoring

cp /tmp/tailor /usr/local/bin/tailor
chmod 755 /usr/local/bin/tailor

cp /tmp/create /usr/local/bin/create
chmod 755 /usr/local/bin/create

cp /tmp/cyberprobe-sync /usr/local/bin/cyberprobe-sync
chmod 755 /usr/local/bin/cyberprobe-sync

cp /tmp/server.conf /etc/openvpn/server.conf
chmod 644 /etc/openvpn/server.conf

cp /tmp/client-connect /usr/local/bin/client-connect
chmod 755 /usr/local/bin/client-connect

# Triggers action in tailor
rm -f /etc/cyberprobe.cfg

echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# Add clients directory for communication between OpenVPN and cyberprobe-sync
# on allocated IP addresses.
mkdir /etc/openvpn/clients
chmod 755 /etc/openvpn/clients
chown nobody /etc/openvpn/clients

echo '----- Config script done ------------------------------------------'

