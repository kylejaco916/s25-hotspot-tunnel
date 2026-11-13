#!/data/data/com.termux/files/usr/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export DEBIAN_FRONTEND=noninteractive
pkg update -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
pkg install -y microsocks net-tools tmux procps termux-tools curl

cp "$SCRIPT_DIR/s25-tunnel" "$PREFIX/bin/s25-tunnel"
chmod +x "$PREFIX/bin/s25-tunnel"

mkdir -p ~/.shortcuts
cat << 'SC_EOF' > ~/.shortcuts/S25-Tunnel-Start
#!/data/data/com.termux/files/usr/bin/bash
s25-tunnel start
read -p "Press Enter to close..."
SC_EOF
chmod +x ~/.shortcuts/S25-Tunnel-Start

grep -q "s25-tunnel" ~/.bashrc 2>/dev/null || cat << 'RC_EOF' >> ~/.bashrc
if ! pgrep -x microsocks >/dev/null 2>&1; then
  "$PREFIX/bin/s25-tunnel" start
fi
RC_EOF

s25-tunnel restart
s25-tunnel test
