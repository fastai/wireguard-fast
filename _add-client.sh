#!/usr/bin/env bash
set -e

i=$1

if [[ ! $SERVER ]]; then
  echo "Please set SERVER" >&2; exit 1
fi

if [[ ! $SUBNET ]]; then
  echo "Please set SUBNET" >&2; exit 1
fi

if [[ ! $i ]]; then
  echo "Please pass client number to create" >&2; exit 1
fi

if ! [[ $(id -u) = 0 ]]; then
  echo "Please run with sudo" >&2; exit 1
fi

mkdir -p clients

wg genkey | tee $i.key | wg pubkey > $i.pub
echo "[Interface]
PrivateKey = $(cat $i.key)
Address = 10.42.42.$i/24
[Peer]
PublicKey = $(cat server.pub)
Endpoint = $SERVER:51820
AllowedIPs = $SUBNET
PersistentKeepalive = 15
" > clients/$i.conf

wg set wg0 peer $(cat $i.pub) endpoint $SERVER:51820 allowed-ips 10.42.42.$i/32
wg-quick save wg0

if [ $SUDO_USER ]; then user=$SUDO_USER
else user=$(whoami); fi
chown -R $user clients
rm $i.{key,pub}

