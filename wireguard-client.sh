#!/usr/bin/env bash
set -e

if ! [[ $(id -u) = 0 ]]; then
  echo "Please run 'sudo $0'" >&2
  exit 1
fi

CONF=$1
if [[ -z $CONF ]]; then
  echo "Usage: $0 conf_file"
  exit 1
fi
if [[ ! -f $CONF ]]; then
  echo "Missing conf file name"
  exit 1
fi

apt-get install -qq wireguard

cp $1 /etc/wireguard/wg0.conf
ufw allow 51820/udp
systemctl start wg-quick@wg0
systemctl enable wg-quick@wg0
wg

