#!/usr/bin/env bash
set -euo pipefail

SERIAL_DEV="${1:-/dev/ttyUSB0}"
BAUD="${2:-115200}"

if [ ! -e "$SERIAL_DEV" ]; then
  echo "ERROR: Serial device not found: $SERIAL_DEV"
  echo
  echo "Available serial devices:"
  ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || true
  exit 1
fi

if command -v picocom >/dev/null 2>&1; then
  echo "Opening serial console with picocom:"
  echo "  Device: $SERIAL_DEV"
  echo "  Baud  : $BAUD"
  echo
  echo "Exit picocom with: Ctrl+A then Ctrl+X"
  sudo picocom -b "$BAUD" "$SERIAL_DEV"
elif command -v minicom >/dev/null 2>&1; then
  echo "Opening serial console with minicom:"
  sudo minicom -D "$SERIAL_DEV" -b "$BAUD"
else
  echo "ERROR: Neither picocom nor minicom is installed."
  echo "Run: sudo apt install -y picocom minicom"
  exit 1
fi
