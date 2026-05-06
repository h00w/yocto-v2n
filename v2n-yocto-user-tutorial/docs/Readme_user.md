# Verify Yocto Linux on Renesas RZ/V2N Development Board

This guide is for end users who want to verify that a Yocto Linux image is working correctly on the **Renesas RZ/V2N Development Board** or **ALP E1M-X V2N** platform.

---

## 1. What You Need

### Hardware

- Renesas RZ/V2N Development Board or ALP E1M-X V2N board
- Power supply
- MicroSD card or supported boot media
- USB-to-UART serial cable
- Ethernet cable
- Linux/Ubuntu PC, WSL2 Ubuntu, or Windows PC with serial terminal software

Optional:

- USB flash drive for USB test
- USB keyboard or mouse for USB test

---

## 2. Install Host Tools

On Ubuntu or WSL2 Ubuntu:

```bash
chmod +x scripts/*.sh
./scripts/setup_host.sh
```

On Windows, install one serial terminal program:

- Tera Term
- PuTTY
- MobaXterm

---

## 3. Flash Yocto Linux Image to SD Card

You should already have an image file:

```text
*.wic
*.wic.gz
*.img
```

Insert SD card and find device:

```bash
lsblk
```

Flash image:

```bash
sudo ./scripts/flash_sd.sh /path/to/image.wic /dev/sdX
```

Example:

```bash
sudo ./scripts/flash_sd.sh ~/Downloads/core-image-weston-rzv2n-evk.wic /dev/sdb
```

> Warning: Choose the correct device. Flashing the wrong disk can erase your computer data.

---

## 4. Connect the Board

1. Insert flashed SD card into the V2N board.
2. Connect USB-to-UART serial cable.
3. Connect Ethernet cable.
4. Connect power supply.
5. Open serial console before powering on if possible.

---

## 5. Open Serial Console

Serial settings:

```text
Baud rate: 115200
Data bits: 8
Parity: None
Stop bits: 1
Flow control: None
```

On Linux:

```bash
./scripts/open_serial_linux.sh /dev/ttyUSB0
```

Alternative:

```bash
sudo picocom -b 115200 /dev/ttyUSB0
```

On Windows, use Tera Term, PuTTY, or MobaXterm with `115200 8N1`.

---

## 6. Boot the Board

Power on the board.

Expected boot sequence:

```text
U-Boot starts
Linux kernel starts
Root filesystem mounts
Login prompt appears
```

Example login prompt:

```text
rzv2n login:
```

Login example:

```text
login: root
password:
```

For many Yocto development images, `root` has an empty password.

---

# Basic Board Verification

Run these commands on the board after login.

## 7. Check Linux Kernel

```bash
uname -a
```

Expected:

- Linux kernel version is shown
- Command returns successfully

## 8. Check OS Information

```bash
cat /etc/os-release
```

Expected:

- Yocto/Poky information is displayed

## 9. Check CPU and Memory

```bash
cat /proc/cpuinfo
free -h
```

Expected:

- CPU information appears
- Memory information appears

## 10. Check Storage

```bash
df -h
lsblk
```

Expected:

- Root filesystem `/` is mounted
- SD card or eMMC device is visible

## 11. Check Device Tree

```bash
cat /proc/device-tree/model
tr '\0' '\n' < /proc/device-tree/compatible
cat /proc/cmdline
```

Expected:

- Board model is shown
- Compatible string is shown
- Kernel boot arguments are shown

## 12. Check Ethernet

```bash
ip addr
```

Look for:

```text
eth0
```

or another Ethernet interface such as:

```text
end0
```

Request IP address:

```bash
udhcpc -i eth0
```

If your interface is not `eth0`, replace it:

```bash
udhcpc -i end0
```

Test IP connectivity:

```bash
ping -c 4 8.8.8.8
```

Test DNS:

```bash
ping -c 4 google.com
```

## 13. Check USB

Insert a USB device.

Run:

```bash
dmesg | tail -50
lsusb
lsblk
```

If a USB flash drive appears as `/dev/sda1`, mount it:

```bash
mkdir -p /mnt/usb
mount /dev/sda1 /mnt/usb
ls -la /mnt/usb
umount /mnt/usb
```

## 14. Check GPIO

```bash
ls /dev/gpiochip*
```

If available:

```bash
gpioinfo
```

Expected:

- GPIO chips are visible

## 15. Check Kernel Logs

```bash
dmesg | grep -i error
dmesg | grep -i fail
dmesg | grep -i eth
dmesg | grep -i usb
dmesg | grep -i mmc
dmesg | grep -i renesas
```

Expected:

- No critical boot errors

---

# Automatic Validation Script

Copy the validation script to the board:

```bash
scp scripts/validate_board.sh root@<BOARD_IP>:/root/
```

Login to board:

```bash
ssh root@<BOARD_IP>
```

Run:

```bash
chmod +x /root/validate_board.sh
/root/validate_board.sh
```

Logs are saved to:

```text
/root/v2n-validation/
```

Create archive:

```bash
tar -czf /root/v2n-validation.tar.gz /root/v2n-validation
```

Copy archive back to host:

```bash
scp root@<BOARD_IP>:/root/v2n-validation.tar.gz ./logs/validation/
```

---

# End User Validation Checklist

| Test | Command | Expected Result | Status |
|---|---|---|---|
| Serial console | Power on board | Boot logs visible | Pending |
| Login | `root` login | Shell prompt appears | Pending |
| Kernel | `uname -a` | Linux kernel version shown | Pending |
| OS | `cat /etc/os-release` | Yocto/Poky information shown | Pending |
| CPU | `cat /proc/cpuinfo` | CPU information shown | Pending |
| Memory | `free -h` | Memory information shown | Pending |
| Storage | `df -h`, `lsblk` | Root filesystem and boot media visible | Pending |
| Device tree | `cat /proc/device-tree/model` | Board model shown | Pending |
| Ethernet | `ip addr` | Ethernet interface visible | Pending |
| DHCP | `udhcpc -i eth0` | IP address assigned | Pending |
| IP ping | `ping -c 4 8.8.8.8` | Ping successful | Pending |
| DNS ping | `ping -c 4 google.com` | DNS works | Pending |
| USB | `lsusb`, `dmesg` | USB device detected | Pending |
| GPIO | `ls /dev/gpiochip*` | GPIO devices visible | Pending |
| Kernel logs | `dmesg` | No critical errors | Pending |

---

# Pass Criteria

The Yocto Linux image is considered working if:

- Board boots to Linux login prompt
- User can login through serial console
- `uname -a` shows Linux kernel information
- Root filesystem is mounted
- Ethernet interface is detected
- Board can receive an IP address
- Board can ping another network device or the internet
- USB device is detected
- Storage device is visible
- GPIO devices are visible
- No critical kernel boot errors are found

---

# Final Result

If all critical checks pass, the board is ready for:

- ALP SDK testing
- Renesas AI SDK integration
- DRP-AI application development
- Camera and vision pipeline testing
- Custom Yocto layer development
- Product-specific Linux image customization
