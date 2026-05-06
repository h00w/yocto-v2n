#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "Usage:"
  echo "  $0 root@<BOARD_IP>"
  echo
  echo "Example:"
  echo "  $0 root@192.168.1.50"
  exit 1
fi

mkdir -p logs/validation

echo "Creating validation archive on board..."
ssh "$TARGET" "tar -czf /root/v2n-validation.tar.gz /root/v2n-validation"

echo "Copying validation archive..."
scp "$TARGET:/root/v2n-validation.tar.gz" "logs/validation/v2n-validation.tar.gz"

echo "Done."
echo "Saved to: logs/validation/v2n-validation.tar.gz"
