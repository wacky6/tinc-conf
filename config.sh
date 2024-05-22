#!/bin/bash
# 
# Generate tinc config
#

NETNAME="overlay"
INTERFACE=overlay0
SUPERNODES=''
SUBNETS=''

read -p 'Tinc name: ' NAME
read -p 'Tinc IP: ' TINC_IP
read -p 'Public IP/Hostname (or blank): ' PUBLIC_IP

while : ; do
    read -p 'Connect To (or blank): ' CONNECT_TO
    [ $CONNECT_TO ] && SUPERNODES="$SUPERNODES $CONNECT_TO" || break
done

while : ; do
    read -p 'Subnet (or blank): ' SUBNET
    [ $SUBNET ] && SUBNETS="$SUBNETS $SUBNET" || break
done

mkdir -p hosts

#### Daemon Config
cat > tinc.conf << _EOF_
Interface = $INTERFACE

Name = $NAME

_EOF_

for S in $SUPERNODES; do
    echo "ConnectTo = $S" >> tinc.conf
done

#### Host Config
CONF=hosts/$NAME

rm -f $CONF

tinc -n $NETNAME generate-ed25519-keys

echo "" >> $CONF
echo "IndirectData = yes" >> $CONF

[[ $PUBLIC_IP ]] \
&& echo "Address = $PUBLIC_IP" >> $CONF

echo "SelfIP = $TINC_IP" >> $CONF   # used by tinc-up
for S in $TINC_IP $SUBNETS ; do
    echo "Subnet = $S" >> $CONF
done

echo "******** Daemon Config ********"
cat tinc.conf
echo ""
echo "******** Host Config $NAME ********"
cat $CONF
echo ""


