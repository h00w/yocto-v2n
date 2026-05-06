# Verify Yocto Linux on Renesas RZ/V2N Development Board

This guide is for end users who want to verify that a Yocto Linux image is working correctly on the **Renesas RZ/V2N Development Board** or **ALP E1M-X V2N** platform.

The goal is simple:

1. Prepare the board.
2. Boot Yocto Linux.
3. Login through the serial console.
4. Check that Linux is running.
5. Verify basic hardware functions.

---

## 1. What You Need

### Hardware

You need:

- Renesas RZ/V2N Development Board or ALP E1M-X V2N board
- Power supply for the board
- MicroSD card or supported boot media
- USB-to-UART serial cable
- Ethernet cable
- Linux PC, Ubuntu PC, or Windows PC with serial terminal software

Optional:

- USB flash drive for USB test
- USB keyboard or mouse for USB test

---

## 2. Software Tools

### On Linux / Ubuntu

Install the required tools:

```bash
sudo apt update
sudo apt install -y minicom picocom net-tools iproute2 usbutils
```

### On Windows

Install one serial terminal program:

- Tera Term
- PuTTY
- MobaXterm

Recommended: **Tera Term** or **MobaXterm**.

---

## 3. Prepare the Boot Media

You should already have a Yocto Linux image file from the ALP SDK or Renesas SDK build.

The image file usually looks like one of these:

```text
*.wic
*.wic.gz
*.img
```

Example:

```text
core-image-weston-rzv2n-evk.wic
```

---

## 4. Flash the Yocto Image to SD Card

### Step 1: Insert the SD Card

Insert the SD card into your PC.

### Step 2: Find the SD Card Device

On Linux:

```bash
lsblk
```

Example output:

```text
sda      500G
sdb       32G
```

In this example, the SD card is:

```text
/dev/sdb
```

> Warning: Make sure you choose the correct device. Flashing the wrong disk can erase your computer data.

### Step 3: Uncompress the Image if Needed

If your image is compressed as `.wic.gz`, uncompress it:

```bash
gzip -dk image-name.wic.gz
```

Example:

```bash
gzip -dk core-image-weston-rzv2n-evk.wic.gz
```

### Step 4: Flash the Image

Replace `/dev/sdX` with your SD card device.

```bash
sudo dd if=image-name.wic of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Example:

```bash
sudo dd if=core-image-weston-rzv2n-evk.wic of=/dev/sdb bs=4M status=progress conv=fsync
sync
```

When finished, safely remove the SD card.

---

## 5. Connect the Board

Connect the following:

1. Insert the flashed SD card into the V2N board.
2. Connect the USB-to-UART serial cable.
3. Connect the Ethernet cable.
4. Connect the board power supply.
5. Do not power on yet if your board has a power switch.

---

## 6. Open the Serial Console

### Serial Settings

Use these settings:

```text
Baud rate: 115200
Data bits: 8
Parity: None
Stop bits: 1
Flow control: None
```

This is often written as:

```text
115200 8N1
```

---

## 7. Serial Console on Linux

Find the serial device:

```bash
ls /dev/ttyUSB*
```

Example:

```text
/dev/ttyUSB0
```

Open serial console with `picocom`:

```bash
sudo picocom -b 115200 /dev/ttyUSB0
```

Or with `minicom`:

```bash
sudo minicom -D /dev/ttyUSB0 -b 115200
```

To exit `picocom`:

```text
Ctrl + A, then Ctrl + X
```

---

## 8. Serial Console on Windows

Open Tera Term, PuTTY, or MobaXterm.

Select the serial COM port, for example:

```text
COM3
COM4
COM5
```

Set the serial speed:

```text
115200
```

Use:

```text
8 data bits
No parity
1 stop bit
No flow control
```

---

## 9. Boot the Board

Power on the board.

You should see boot messages in the serial console.

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

or:

```text
localhost login:
```

---

## 10. Login to Linux

Use the login account provided by your image.

Common default login examples:

```text
root
```

Password may be empty, or provided by the SDK image documentation.

If password is empty, just press Enter.

Example:

```text
login: root
password:
```

After successful login, you should see a Linux shell prompt:

```text
root@rzv2n:~#
```

---

# Basic Verification Steps

Run the following tests after logging in.

---

## 11. Check Linux Kernel

Run:

```bash
uname -a
```

Expected result:

- Linux kernel version is shown
- Board does not crash
- Command returns successfully

Example:

```text
Linux rzv2n 5.10.x ...
```

---

## 12. Check Operating System Information

Run:

```bash
cat /etc/os-release
```

Expected result:

- Yocto or Poky information is displayed
- OS version is displayed

Example:

```text
ID=poky
NAME="Poky"
```

---

## 13. Check CPU Information

Run:

```bash
cat /proc/cpuinfo
```

Expected result:

- CPU information is shown
- Arm processor information appears

---

## 14. Check Memory

Run:

```bash
free -h
```

Expected result:

- Total memory is shown
- Used and free memory are displayed

Example:

```text
              total        used        free
Mem:          3.7Gi       120Mi       3.2Gi
```

---

## 15. Check Storage

Run:

```bash
df -h
```

Expected result:

- Root filesystem `/` is mounted
- Available storage is shown

Run:

```bash
lsblk
```

Expected result:

- SD card or eMMC device is visible

Common devices:

```text
mmcblk0
mmcblk1
```

---

## 16. Check Boot Arguments

Run:

```bash
cat /proc/cmdline
```

Expected result:

- Kernel boot arguments are displayed
- Root filesystem location is shown

---

## 17. Check Device Tree Board Name

Run:

```bash
cat /proc/device-tree/model
```

Expected result:

- Board model is displayed

Example:

```text
Renesas RZ/V2N EVK
```

If the output does not end with a new line, this is normal.

---

## 18. Check Network Interface

Run:

```bash
ip addr
```

Expected result:

- Ethernet interface is visible
- Usually named `eth0` or `end0`

Example:

```text
eth0
```

---

## 19. Get IP Address

If the board does not already have an IP address, request one using DHCP.

Try:

```bash
udhcpc -i eth0
```

If your interface is not `eth0`, replace it with the correct interface name.

Example:

```bash
udhcpc -i end0
```

Then check again:

```bash
ip addr
```

Expected result:

- Board receives an IP address

Example:

```text
inet 192.168.1.50/24
```

---

## 20. Test Network Connection

Ping your router or internet IP:

```bash
ping -c 4 8.8.8.8
```

Expected result:

```text
4 packets transmitted, 4 received
```

Then test DNS:

```bash
ping -c 4 google.com
```

Expected result:

```text
4 packets transmitted, 4 received
```

If IP ping works but `google.com` fails, the issue is likely DNS.

Check DNS file:

```bash
cat /etc/resolv.conf
```

---

## 21. Check USB

Insert a USB flash drive or USB device.

Run:

```bash
dmesg | tail -50
```

Expected result:

- Kernel detects the USB device

Run:

```bash
lsusb
```

Expected result:

- USB device is listed

Run:

```bash
lsblk
```

If a USB flash drive is connected, you may see something like:

```text
sda
sda1
```

---

## 22. Mount USB Flash Drive

If a USB storage device appears as `/dev/sda1`, mount it:

```bash
mkdir -p /mnt/usb
mount /dev/sda1 /mnt/usb
ls -la /mnt/usb
```

Unmount it:

```bash
umount /mnt/usb
```

Expected result:

- USB flash drive can be mounted
- Files can be listed

---

## 23. Check GPIO Devices

Run:

```bash
ls /dev/gpiochip*
```

Expected result:

```text
/dev/gpiochip0
/dev/gpiochip1
```

If `gpioinfo` is available, run:

```bash
gpioinfo
```

Expected result:

- GPIO chips and GPIO lines are displayed

If `gpioinfo` is not found, GPIO tools may not be installed in the image.

---

## 24. Check Kernel Messages

Run:

```bash
dmesg | less
```

Look for critical errors.

Useful commands:

```bash
dmesg | grep -i error
dmesg | grep -i fail
dmesg | grep -i eth
dmesg | grep -i usb
dmesg | grep -i mmc
dmesg | grep -i renesas
```

Expected result:

- No critical boot failure
- Ethernet, USB, storage, and Renesas drivers appear in logs

---

## 25. Check Running Services

If the image uses systemd, run:

```bash
systemctl --failed
```

Expected result:

```text
0 loaded units listed
```

If systemd is not available, this command may not work. That is acceptable for minimal Yocto images.

---

# Save Verification Logs

It is recommended to save the test results.

Create a directory:

```bash
mkdir -p /root/v2n-validation
```

Save basic logs:

```bash
uname -a > /root/v2n-validation/kernel.txt
cat /etc/os-release > /root/v2n-validation/os-release.txt
cat /proc/cpuinfo > /root/v2n-validation/cpuinfo.txt
free -h > /root/v2n-validation/memory.txt
df -h > /root/v2n-validation/storage.txt
ip addr > /root/v2n-validation/network.txt
dmesg > /root/v2n-validation/dmesg.txt
cat /proc/cmdline > /root/v2n-validation/cmdline.txt
cat /proc/device-tree/model > /root/v2n-validation/device-tree-model.txt
```

Optional network logs:

```bash
ping -c 4 8.8.8.8 > /root/v2n-validation/ping-ip.txt
ping -c 4 google.com > /root/v2n-validation/ping-dns.txt
```

List saved files:

```bash
ls -la /root/v2n-validation
```

---

# End User Validation Checklist

Use this checklist to confirm that Yocto Linux is working.

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
| Internet IP ping | `ping -c 4 8.8.8.8` | Ping successful | Pending |
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
- No critical kernel boot errors are found

---

# Common Problems and Fixes

## Problem 1: No Serial Output

Check:

- UART cable is connected correctly
- Correct COM port or `/dev/ttyUSBx` is selected
- Baud rate is `115200`
- Board is powered on
- Ground wire is connected
- TX and RX may need to be swapped

---

## Problem 2: Board Does Not Boot

Check:

- SD card is flashed correctly
- Boot mode switch is set to SD/eMMC boot
- Power supply is correct
- Image matches the board type
- Serial console shows U-Boot or boot errors

---

## Problem 3: Cannot Login

Check:

- Try username `root`
- Try empty password
- Check image documentation for default username and password
- Rebuild or reflash image if root filesystem is corrupted

---

## Problem 4: No Ethernet Interface

Check:

```bash
ip addr
dmesg | grep -i eth
dmesg | grep -i phy
```

Possible causes:

- Ethernet cable disconnected
- DHCP server not available
- Device tree issue
- Ethernet driver not loaded

---

## Problem 5: Ping IP Works but DNS Fails

Check:

```bash
cat /etc/resolv.conf
```

Temporary fix:

```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

Then try:

```bash
ping -c 4 google.com
```

---

## Problem 6: USB Device Not Detected

Check:

```bash
dmesg | tail -50
lsusb
```

Possible causes:

- USB device not powered
- USB driver missing
- USB port not enabled in device tree
- Faulty USB cable or adapter

---

## Problem 7: Root Filesystem Is Read-Only

Check:

```bash
mount
```

Try remounting:

```bash
mount -o remount,rw /
```

If it still fails, the image or SD card may be corrupted.

---

# Recommended Validation Report

After testing, create a short report:

```markdown
# V2N Yocto Linux Validation Report

## Board

- Board:
- Image name:
- Image build date:
- Boot media:
- Tester:
- Test date:

## Result

- Boot to Linux: Pass / Fail
- Serial login: Pass / Fail
- Ethernet: Pass / Fail
- USB: Pass / Fail
- Storage: Pass / Fail
- GPIO visible: Pass / Fail

## Notes

Write any issue or observation here.

## Attached Logs

- kernel.txt
- os-release.txt
- network.txt
- dmesg.txt
```

---

# Final Result

If all critical checks pass, the board is ready for:

- ALP SDK testing
- Renesas AI SDK integration
- DRP-AI application development
- Camera and vision pipeline testing
- Custom Yocto layer development
- Product-specific Linux image customization



# yocto-v2n
