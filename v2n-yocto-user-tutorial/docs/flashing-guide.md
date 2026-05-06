# Flashing Guide

## 1. Insert SD Card

Insert the SD card into your PC.

## 2. Find Device

```bash
lsblk
```

Example:

```text
/dev/sdb
```

## 3. Flash Image

```bash
sudo ./scripts/flash_sd.sh /path/to/image.wic /dev/sdX
```

Example:

```bash
sudo ./scripts/flash_sd.sh ~/Downloads/core-image-weston-rzv2n-evk.wic /dev/sdb
```

## 4. Safely Remove SD Card

```bash
sync
```

Remove the card and insert it into the V2N board.
