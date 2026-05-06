#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage:"
  echo "  sudo $0 <image.wic|image.wic.gz|image.img> <device>"
  echo
  echo "Example:"
  echo "  sudo $0 ~/Downloads/core-image-weston-rzv2n-evk.wic /dev/sdb"
  echo
  echo "WARNING: The target device will be erased."
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

IMAGE="$1"
DEVICE="$2"

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: Please run with sudo."
  exit 1
fi

if [ ! -f "$IMAGE" ]; then
  echo "ERROR: Image file not found: $IMAGE"
  exit 1
fi

if [ ! -b "$DEVICE" ]; then
  echo "ERROR: Target device is not a block device: $DEVICE"
  echo "Run lsblk to check available devices."
  exit 1
fi

echo "============================================================"
echo " Flash Yocto Image to SD/eMMC Boot Media"
echo "============================================================"
echo "Image : $IMAGE"
echo "Device: $DEVICE"
echo

echo "Current block devices:"
lsblk
echo

read -r -p "Type YES to erase and flash $DEVICE: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
  echo "Cancelled."
  exit 0
fi

TMP_IMAGE=""
FLASH_IMAGE="$IMAGE"

if [[ "$IMAGE" == *.gz ]]; then
  TMP_IMAGE="$(mktemp /tmp/v2n-image-XXXXXX.wic)"
  echo "Uncompressing $IMAGE to temporary file..."
  gzip -dc "$IMAGE" > "$TMP_IMAGE"
  FLASH_IMAGE="$TMP_IMAGE"
fi

echo "Unmounting mounted partitions on $DEVICE..."
for part in $(lsblk -ln -o NAME "$DEVICE" | tail -n +2); do
  mountpoint="/dev/$part"
  if mount | grep -q "$mountpoint"; then
    umount "$mountpoint" || true
  fi
done

echo "Flashing image..."
dd if="$FLASH_IMAGE" of="$DEVICE" bs=4M status=progress conv=fsync

echo "Syncing..."
sync

if [ -n "$TMP_IMAGE" ] && [ -f "$TMP_IMAGE" ]; then
  rm -f "$TMP_IMAGE"
fi

echo "Done."
echo "You may now safely remove the boot media and insert it into the V2N board."
