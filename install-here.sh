#!/bin/sh

echo '----- Install script starting ------------------------------'

cd /tmp

id
apt install -y liblua5.2-0
apt install -y libboost-regex1.58.0
dpkg -i cyberprobe.deb

apt install -y openvpn
apt install -y awscli

systemctl enable cyberprobe
systemctl enable openvpn

echo '----- Install script done ------------------------------'





