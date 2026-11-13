# S25 Ultra (Android 16) + Debian 13 Hotspot Bypass Tunnel

Userspace SOCKS5 tunneling suite that routes Debian 13 system and Kali Distrobox traffic through Termux (microsocks) on an unrooted Samsung Galaxy S25 Ultra (Android 16), bypassing the hardware DUN tethering bearer (rmnet_data1/2) and utilizing primary unthrottled cellular data (rmnet_data0).

## Core Features
- Dual-Mode Transport: Wired USB ADB (127.0.0.1:1080) and wireless Wi-Fi Hotspot (auto-discovers Android 16 randomized 10.x.x.x DHCP gateways).
- Android 16 Hardening: Elevates open file descriptors (32768 FDs) for Burp Suite / OWASP ZAP concurrency, holds an Android PARTIAL_WAKE_LOCK, and runs inside a self-healing tmux watchdog loop.
- Browser & TLS 1.3 Optimization: Clamps tun0 MTU to 1280, enables RFC 4821 TCP MTU probing, disables IPv6 leaks, rejects UDP 443 (QUIC) for instant HTTP/2 TCP fallback, and patches dnscrypt-proxy (force_tcp = true, block_ipv6 = true).
- Zero-Leak Kill-Switch & Auto-Reconnect: Locks wlp2s0 via nftables so only TCP port 1080 and DHCP (UDP 67/68) traverse Wi-Fi, paired with a NetworkManager dispatcher hook (99-s25-auto).

## Quick Installation

1. On Samsung S25 Ultra (Termux):

    bash ./termux-s25/install-termux.sh

2. On Debian 13 Host (Openbox):

    sudo bash ./debian13-client/install-debian.sh
