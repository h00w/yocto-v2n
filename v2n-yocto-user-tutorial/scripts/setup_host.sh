#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo " V2N Yocto End-User Host Setup"
echo "============================================================"

if ! command -v apt >/dev/null 2>&1; then
  echo "ERROR: This script is intended for Ubuntu/Debian-based systems."
  exit 1
fi

echo "[1/4] Updating package index..."
sudo apt update

echo "[2/4] Installing required host tools..."
sudo apt install -y \
  minicom \
  picocom \
  net-tools \
  iproute2 \
  usbutils \
  gzip \
  coreutils \
  util-linux \
  bmap-tools \
  openssh-client \
  rsync

echo "[3/4] Checking useful tools..."
for tool in lsblk dd gzip sync picocom ssh scp; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "OK: $tool"
  else
    echo "MISSING: $tool"
  fi
done

echo "[4/4] Done."
echo
echo "Next steps:"
echo "  1. Insert SD card and run: lsblk"
echo "  2. Flash image: sudo ./scripts/flash_sd.sh /path/to/image.wic /dev/sdX"
echo "  3. Open serial: ./scripts/open_serial_linux.sh /dev/ttyUSB0"
