#!/bin/sh
set -eu

: "${PRINTER_IP:?PRINTER_IP is required}"
: "${PRINTER_MODEL:?PRINTER_MODEL is required}"

CFG=/etc/opt/brother/scanner/brscan4
mkdir -p "$CFG"

if [ ! -s "$CFG/Brsane4.ini" ]; then
  cp -a /opt/brother/scanner/brscan4/Brsane4.ini "$CFG/"
fi
if [ ! -d "$CFG/models4" ]; then
  cp -a /opt/brother/scanner/brscan4/models4 "$CFG/"
fi
if ! grep -q 'IP-ADDRESS=' "$CFG/brsanenetdevice4.cfg" 2>/dev/null; then
  brsaneconfig4 -a name=home model="$PRINTER_MODEL" ip="$PRINTER_IP"
fi

mkdir -p /tmp/scan
mkdir -p "${SCAN_DROP_DIR:-/consume}"

echo "configured devices:"
scanimage -L || true

echo "scan key diagnosis:"
brscan-skey --diagnosis || true

brscan-skey

exec sleep infinity
