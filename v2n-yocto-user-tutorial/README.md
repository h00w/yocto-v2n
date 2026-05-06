# V2N Yocto Linux End-User Tutorial

This repository contains simple end-user instructions and helper scripts to verify that a Yocto Linux image is working on a **Renesas RZ/V2N Development Board** or **ALP E1M-X V2N** platform.

## What This Tutorial Helps You Do

1. Prepare the host PC.
2. Flash a Yocto Linux image to SD card.
3. Boot the V2N development board.
4. Login through serial console.
5. Verify Linux, Ethernet, USB, storage, GPIO, and basic system health.
6. Save validation logs and generate a validation report.

---

## Repository Structure

```text
v2n-yocto-user-tutorial/
├── README.md
├── docs/
│   ├── Readme_user.md
│   ├── flashing-guide.md
│   ├── serial-console-guide.md
│   └── validation-checklist.md
├── scripts/
│   ├── setup_host.sh
│   ├── flash_sd.sh
│   ├── open_serial_linux.sh
│   ├── validate_board.sh
│   └── collect_report.sh
├── config/
│   ├── board.env
│   ├── serial.env
│   └── wslconfig.example
├── examples/
│   └── validation-report-template.md
├── logs/
│   ├── boot/
│   ├── build/
│   └── validation/
└── reports/
```

---

## Quick Start

### 1. Install host tools

On Ubuntu or WSL2 Ubuntu:

```bash
chmod +x scripts/*.sh
./scripts/setup_host.sh
```

### 2. Flash Yocto image to SD card

Insert SD card and check the device name:

```bash
lsblk
```

Flash the image:

```bash
sudo ./scripts/flash_sd.sh /path/to/image.wic /dev/sdX
```

Example:

```bash
sudo ./scripts/flash_sd.sh ~/Downloads/core-image-weston-rzv2n-evk.wic /dev/sdb
```

If your image is compressed as `.wic.gz`, the script will uncompress a temporary copy automatically.

> Warning: Make sure `/dev/sdX` is the SD card, not your computer disk.

### 3. Open serial console

Connect the USB-to-UART cable.

```bash
./scripts/open_serial_linux.sh /dev/ttyUSB0
```

Default serial setting:

```text
115200 8N1
```

### 4. Boot the board

1. Insert flashed SD card into the V2N board.
2. Connect UART serial cable.
3. Connect Ethernet.
4. Power on the board.
5. Wait for Linux login prompt.

Example login:

```text
login: root
password:
```

For many development Yocto images, the default user is `root` and the password may be empty.

### 5. Run board validation

After the board has network access:

```bash
scp scripts/validate_board.sh root@<BOARD_IP>:/root/
ssh root@<BOARD_IP>
chmod +x /root/validate_board.sh
/root/validate_board.sh
```

The script creates validation logs in:

```text
/root/v2n-validation/
```

### 6. Collect validation report

From the host PC:

```bash
./scripts/collect_report.sh root@<BOARD_IP>
```

The report archive is saved to:

```text
logs/validation/v2n-validation.tar.gz
```

---

## Pass Criteria

Yocto Linux is considered working when:

- Board boots to Linux login prompt
- Serial console works
- User can login
- `uname -a` shows Linux kernel information
- Root filesystem is mounted
- Ethernet interface is detected
- Board receives an IP address
- Board can ping another network device or the internet
- USB device is detected
- Storage device is visible
- GPIO devices are visible
- No critical kernel boot errors are found

---

## Main Documentation

See:

```text
docs/Readme_user.md
```
