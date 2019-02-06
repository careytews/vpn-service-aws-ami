#!/bin/bash

s3=$(wget -q -O- http://169.254.169.254/latest/user-data)

if [ "$s3" != "" ]
then

  if [ ! -d /key ]
  then
    mkdir /key
  fi

fi

aws s3 cp ${s3}/vpn-creds/cert.server /vpn-creds/cert.server
aws s3 cp ${s3}/vpn-creds/key.server /vpn-creds/key.server
aws s3 cp ${s3}/vpn-creds/dh.server /vpn-creds/dh.server
aws s3 cp ${s3}/vpn-creds/ta.key /vpn-creds/ta.key
aws s3 cp ${s3}/vpn-creds/cert.ca /vpn-creds/cert.ca
aws s3 cp ${s3}/vpn-creds/cert.allocator /vpn-creds/cert.allocator
aws s3 cp ${s3}/vpn-creds/key.allocator /vpn-creds/key.allocator

aws s3 cp ${s3}/probe-creds/cert.vpn /probe-creds/cert.vpn
aws s3 cp ${s3}/probe-creds/key.vpn /probe-creds/key.vpn
aws s3 cp ${s3}/probe-creds/cert.ca /probe-creds/cert.ca

aws s3 cp ${s3}/cyberprobe.cfg /etc/cyberprobe.cfg

# Fix SELinux attributes
chcon -R system_u:object_r:openvpn_etc_t:s0 /probe-creds/
chcon -R system_u:object_r:openvpn_etc_t:s0 /vpn-creds/
restorecon -R /etc/openvpn/

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

