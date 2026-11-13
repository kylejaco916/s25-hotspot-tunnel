#!/usr/bin/env bash
set -e
[ "$EUID" -ne 0 ] && echo "[!] Run with sudo: sudo bash $0" && exit 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="https:"

apt-get update -y
apt-get install -y adb curl unzip iproute2 procps psmisc bind9-dnsutils tcpdump nftables

if ! command -v tun2socks >/dev/null 2>&1; then
  ARCH=$(uname -m)
  [ "$ARCH" = "x86_64" ] && T2S="linux-amd64" || T2S="linux-arm64"
  curl -Lo /tmp/t2s.zip "$S//github.com/xjasonlyu/tun2socks/releases/download/v2.5.2/tun2socks-${T2S}.zip"
  unzip -o /tmp/t2s.zip -d /tmp/
  mv "/tmp/tun2socks-${T2S}" /usr/local/bin/tun2socks
  chmod +x /usr/local/bin/tun2socks
  rm -f /tmp/t2s.zip
fi

TOML="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
if [ -f "$TOML" ]; then
  sed -i "/^force_tcp/d; /^ipv4_servers/d; /^ipv6_servers/d; /^block_ipv6/d" "$TOML"
  sed -i "1i force_tcp = true\nipv4_servers = true\nipv6_servers = false\nblock_ipv6 = true" "$TOML"
  systemctl daemon-reload
  systemctl restart dnscrypt-proxy.socket dnscrypt-proxy.service
fi

chattr -i /etc/resolv.conf 2>/dev/null || true
printf "# Locked by s25-client\nnameserver 127.0.0.1\n" > /etc/resolv.conf
chattr +i /etc/resolv.conf 2>/dev/null || true

cp "$SCRIPT_DIR/s25-client" /usr/local/bin/s25-client
chmod +x /usr/local/bin/s25-client
cp "$SCRIPT_DIR/nftables-killswitch.conf" /etc/nftables.conf
systemctl enable --now nftables
nft -f /etc/nftables.conf
cp "$SCRIPT_DIR/99-s25-auto" /etc/NetworkManager/dispatcher.d/99-s25-auto
chmod 755 /etc/NetworkManager/dispatcher.d/99-s25-auto
chown root:root /etc/NetworkManager/dispatcher.d/99-s25-auto
echo "[+] Debian 13 S25 Client installed!"
