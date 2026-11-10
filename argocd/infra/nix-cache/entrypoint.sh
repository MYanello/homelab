#!/bin/bash
set -euo pipefail

if [ ! -f /nix/var/nix/db/db.sqlite ]; then
  mkdir -p /nix/store /nix/var/nix/db /nix/var/log/nix/drvs /nix/var/nix/gcroots
  chown -R nix:nix /nix
  su -s /bin/sh nix -c "nix-store --load-db </dev/null"
fi

install -m 0600 -o nix -g nix /mnt/ssh-keys/authorized_keys /home/nix/.ssh/authorized_keys
install -m 0400 -o nobody -g nogroup /etc/nix/cache-secret-src/cache.key /keys/cache.key

su -s /bin/sh nobody -c "exec harmonia-cache" &
HARMONIA_PID=$!
/usr/sbin/sshd -D -e &
SSHD_PID=$!

trap 'kill -TERM $HARMONIA_PID $SSHD_PID 2>/dev/null' TERM INT
wait -n
kill -TERM "$HARMONIA_PID" "$SSHD_PID" 2>/dev/null || true
wait || true
exit 1
