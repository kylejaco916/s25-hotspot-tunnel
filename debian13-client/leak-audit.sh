#!/usr/bin/env bash
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"
GW=$(ip -4 route show default | awk '{print $3}' | head -n1)
echo "[*] Capturing non-1080 packets on wlp2s0 during a 5 MB download..."
timeout 8 tcpdump -ni wlp2s0 -c 500 "not (host $GW and tcp port 1080) and not arp and not udp port 67 and not udp port 68" > /tmp/leak_audit.txt 2>&1 &
PID=$!
sleep 1
curl -s4 --max-time 15 -w "Downloaded: %{size_download} bytes in %{time_total}s\n" -o /dev/null "https://speed.cloudflare.com/__down?bytes=5000000"
kill -INT $PID 2>/dev/null || true
wait $PID 2>/dev/null || true
echo "========================================================"
cat /tmp/leak_audit.txt
echo "========================================================"
