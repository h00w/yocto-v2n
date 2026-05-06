# ALP SDK for Renesas RZ/V2N

ALP SDK provides the internal development baseline for building, customizing, deploying, and validating Linux and AI software on the **ALP E1M-X V2N** platform based on the **Renesas RZ/V2N** processor.

The first development milestone is to build and validate a **Yocto Linux image** for the V2N development board.

---

# Linux Yocto on V2N Dev Boards

## 1. Purpose

This guide explains how to set up the development environment, build a Yocto Linux image, flash it to boot media, boot the Renesas RZ/V2N Dev Board, and validate basic board functionality.

This is the baseline required before developing:

- ALP SDK board support packages
- Custom Yocto layers
- AI SDK integration
- Camera and vision pipelines
- DRP-AI application demos
- Production-ready Linux images for ALP hardware

---

## 2. Target Hardware

| Item | Description |
|---|---|
| Board | Renesas RZ/V2N Dev Board / ALP E1M-X V2N |
| Processor | Renesas RZ/V2N |
| AI Accelerator | DRP-AI3 |
| Boot Media | SD card or eMMC |
| Console | UART serial console |
| Network | Ethernet |

---

## 3. Development Host

Recommended host environment:

| Item | Recommendation |
|---|---|
| OS | Ubuntu Linux or WSL2 Ubuntu |
| Preferred WSL Version | WSL2 |
| Recommended Ubuntu | Ubuntu 20.04 LTS / 22.04 LTS / 24.04 LTS |
| RAM | 16 GB minimum, 32 GB recommended |
| Disk Space | Minimum 120 GB free |
| CPU | 8 cores recommended |
| Filesystem | Linux ext4 filesystem |

> For WSL2 users: build inside the Linux filesystem, not inside `/mnt/c` or `/mnt/d`.

Recommended workspace:

```bash
mkdir -p ~/work/alplab/v2n
cd ~/work/alplab/v2n
```

---

## 4. Install Host Dependencies

Update the system:

```bash
sudo apt update
sudo apt upgrade -y
```

Install Yocto build dependencies:

```bash
sudo apt install -y \
  gawk wget git diffstat unzip texinfo gcc build-essential \
  chrpath socat cpio python3 python3-pip python3-pexpect \
  xz-utils debianutils iputils-ping python3-git python3-jinja2 \
  libegl1-mesa libsdl1.2-dev pylint xterm zstd lz4 \
  file locales bmap-tools
```

Enable UTF-8 locale:

```bash
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

Check locale:

```bash
locale
```

Expected output should include:

```text
LANG=en_US.UTF-8
```

---

## 5. Recommended WSL2 Configuration

If using WSL2, create or edit this file on Windows:

```text
C:\Users\<YOUR_USERNAME>\.wslconfig
```

Recommended content:

```ini
[wsl2]
memory=24GB
processors=8
swap=16GB
localhostForwarding=true
```

Restart WSL:

```powershell
wsl --shutdown
```

Then reopen Ubuntu.

---

## 6. Clone ALP SDK Repository

Clone this repository:

```bash
cd ~/work/alplab
git clone https://github.com/alplabai/alp-sdk.git
cd alp-sdk
```

Recommended branch for V2N Yocto work:

```bash
git checkout -b bringup/v2n-yocto-linux
```

---

## 7. Recommended Project Structure

The repository should follow this structure:

```text
alp-sdk/
├── README.md
├── docs/
│   └── v2n/
│       ├── yocto-build.md
│       ├── flashing.md
│       ├── board-bringup.md
│       ├── validation-checklist.md
│       └── known-issues.md
├── meta-alp/
│   ├── conf/
│   ├── recipes-core/
│   ├── recipes-kernel/
│   ├── recipes-bsp/
│   └── recipes-alp/
├── scripts/
│   ├── setup-host.sh
│   ├── build-v2n.sh
│   ├── flash-sd.sh
│   └── collect-logs.sh
└── logs/
    ├── build/
    ├── boot/
    └── validation/
```

Create the directories:

```bash
mkdir -p docs/v2n
mkdir -p meta-alp
mkdir -p scripts
mkdir -p logs/build logs/boot logs/validation
```

---

## 8. Download Renesas RZ/V2N AI SDK Source

Download the **Renesas RZ/V2N AI SDK Source Code** package from the Renesas website.

Place the downloaded source package outside the Git repository:

```bash
mkdir -p ~/work/alplab/v2n/renesas-src
cd ~/work/alplab/v2n/renesas-src
```

Extract the package:

```bash
unzip <RENESAS_RZV2N_AI_SDK_SOURCE>.zip
```

or, if the package is compressed as `.tar.gz`:

```bash
tar -xvf <RENESAS_RZV2N_AI_SDK_SOURCE>.tar.gz
```

> Replace `<RENESAS_RZV2N_AI_SDK_SOURCE>` with the actual downloaded filename.

---

## 9. Initialize Yocto Build Environment

Go to the extracted Renesas source directory:

```bash
cd ~/work/alplab/v2n/renesas-src/<RENESAS_SDK_SOURCE_DIRECTORY>
```

Initialize the Yocto build environment.

Depending on the Renesas SDK package, use one of the following:

```bash
source poky/oe-init-build-env build
```

or:

```bash
source oe-init-build-env build
```

After initialization, you should be inside the `build` directory.

Check that the configuration directory exists:

```bash
ls conf
```

Expected files:

```text
bblayers.conf
local.conf
```

---

## 10. Configure Target Machine

Open the Yocto local configuration file:

```bash
nano conf/local.conf
```

Set the target machine for RZ/V2N.

Example:

```conf
MACHINE = "rzv2n-evk"
```

> The exact `MACHINE` name depends on the Renesas BSP release.

To find the available machine configuration files:

```bash
find ../ -path "*/conf/machine/*.conf"
```

Look for files related to RZ/V2N, for example:

```text
rzv2n-evk.conf
rzv2n.conf
```

Verify the selected machine:

```bash
bitbake -e | grep "^MACHINE="
```

---

## 11. Check Yocto Layers

Show active layers:

```bash
bitbake-layers show-layers
```

The build should include Renesas, Poky, OpenEmbedded, and other required BSP layers.

Typical layer categories include:

```text
poky/meta
poky/meta-poky
poky/meta-yocto-bsp
meta-openembedded/meta-oe
meta-openembedded/meta-python
meta-openembedded/meta-networking
meta-renesas
meta-rz-features
```

---

## 12. Add ALP Custom Layer

The ALP custom layer is used for board-specific changes, SDK packages, applications, and future production image customization.

From the Yocto build directory:

```bash
bitbake-layers create-layer ../meta-alp
bitbake-layers add-layer ../meta-alp
```

Check that the layer was added:

```bash
bitbake-layers show-layers
```

You should see:

```text
meta-alp
```

---

## 13. Find Available Image Recipes

List available image recipes:

```bash
bitbake-layers show-recipes | grep image
```

Possible image names may include:

```text
core-image-minimal
core-image-weston
renesas-image
rzv2n-ai-sdk-image
```

> Use the image recipe recommended by the Renesas RZ/V2N AI SDK documentation.

---

## 14. Build Yocto Linux Image

Build the selected image.

Example:

```bash
bitbake core-image-weston
```

or:

```bash
bitbake <RENESAS_IMAGE_RECIPE>
```

Example placeholder:

```bash
bitbake rzv2n-ai-sdk-image
```

The first build can take several hours depending on host performance.

---

## 15. Locate Build Output

After a successful build, images are generated under:

```bash
tmp/deploy/images/<machine>/
```

Example:

```bash
ls -lh tmp/deploy/images/${MACHINE}/
```

Expected output files may include:

```text
u-boot.bin
Image
*.dtb
*.wic
*.wic.gz
*.ext4
*.tar.bz2
modules-*.tgz
```

---

## 16. Flash Image to SD Card

Insert the SD card into the host machine.

Find the device name:

```bash
lsblk
```

Example:

```text
/dev/sdb
```

> Be careful. Selecting the wrong device can erase your host disk.

Go to the deploy image directory:

```bash
cd tmp/deploy/images/${MACHINE}/
```

If the image is compressed:

```bash
gzip -dk <image-name>.wic.gz
```

Flash the image:

```bash
sudo dd if=<image-name>.wic of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Replace `/dev/sdX` with your SD card device.

Example:

```bash
sudo dd if=core-image-weston-rzv2n-evk.wic of=/dev/sdb bs=4M status=progress conv=fsync
sync
```

If a `.bmap` file is available, you can use:

```bash
sudo bmaptool copy <image-name>.wic /dev/sdX
```

---

## 17. Connect the V2N Dev Board

Connect the following:

- Power supply
- UART serial cable
- Ethernet cable
- SD card or selected boot media
- USB peripherals if required

Serial console settings:

```text
Baud rate: 115200
Data bits: 8
Parity: None
Stop bits: 1
Flow control: None
```

On Linux:

```bash
sudo minicom -D /dev/ttyUSB0 -b 115200
```

or:

```bash
picocom -b 115200 /dev/ttyUSB0
```

On Windows, use one of:

- Tera Term
- PuTTY
- MobaXterm

---

## 18. Boot the Board

Power on the board.

Expected boot sequence:

```text
U-Boot starts
Linux kernel loads
Root filesystem is mounted
Login prompt appears on serial console
```

Capture the boot log and save it:

```text
logs/boot/v2n-first-boot.log
```

The boot log should include:

- U-Boot version
- Kernel version
- Device tree name
- Root filesystem mount information
- Login prompt
- Network initialization logs
- Any warnings or errors

---

## 19. First Boot Checks

After logging in through serial console, run:

```bash
uname -a
```

Check OS information:

```bash
cat /etc/os-release
```

Check CPU information:

```bash
cat /proc/cpuinfo
```

Check memory:

```bash
free -h
```

Check disk usage:

```bash
df -h
```

Check kernel logs:

```bash
dmesg | less
```

If systemd is used, check failed services:

```bash
systemctl --failed
```

Save logs:

```bash
dmesg > logs/validation/dmesg.txt
uname -a > logs/validation/kernel-version.txt
cat /etc/os-release > logs/validation/os-release.txt
```

---

## 20. Network Validation

Check network interfaces:

```bash
ip addr
```

Expected interface:

```text
eth0
```

Request IP address if needed:

```bash
udhcpc -i eth0
```

Check assigned IP:

```bash
ip addr show eth0
```

Ping external IP:

```bash
ping -c 4 8.8.8.8
```

Ping domain:

```bash
ping -c 4 google.com
```

Save result:

```bash
ip addr > logs/validation/network-ip.txt
ping -c 4 8.8.8.8 > logs/validation/network-ping-ip.txt
ping -c 4 google.com > logs/validation/network-ping-dns.txt
```

---

## 21. USB Validation

Insert a USB device.

Check USB detection:

```bash
dmesg | tail -50
lsusb
lsblk
```

If USB storage appears, mount it:

```bash
mkdir -p /mnt/usb
mount /dev/sdX1 /mnt/usb
ls -la /mnt/usb
umount /mnt/usb
```

Save result:

```bash
lsusb > logs/validation/usb-lsusb.txt
lsblk > logs/validation/usb-lsblk.txt
dmesg | tail -100 > logs/validation/usb-dmesg.txt
```

---

## 22. Storage Validation

Check storage devices:

```bash
lsblk
```

Check partitions:

```bash
fdisk -l
```

Check root filesystem:

```bash
df -h /
```

Check SD/eMMC devices:

```bash
ls /dev/mmcblk*
```

Save result:

```bash
lsblk > logs/validation/storage-lsblk.txt
df -h > logs/validation/storage-df.txt
```

---

## 23. GPIO Validation

Check GPIO devices:

```bash
ls /dev/gpiochip*
```

If GPIO tools are available:

```bash
gpioinfo
```

Read GPIO line:

```bash
gpioget gpiochip0 <line-number>
```

Set GPIO line:

```bash
gpioset gpiochip0 <line-number>=1
gpioset gpiochip0 <line-number>=0
```

> GPIO line mapping must be checked against the board schematic and device tree.

Save result:

```bash
gpioinfo > logs/validation/gpioinfo.txt
```

---

## 24. Device Tree Validation

Check loaded board model:

```bash
cat /proc/device-tree/model
```

Check compatible string:

```bash
tr '\0' '\n' < /proc/device-tree/compatible
```

Check boot arguments:

```bash
cat /proc/cmdline
```

Save result:

```bash
cat /proc/device-tree/model > logs/validation/device-tree-model.txt
tr '\0' '\n' < /proc/device-tree/compatible > logs/validation/device-tree-compatible.txt
cat /proc/cmdline > logs/validation/cmdline.txt
```

---

## 25. Basic Validation Checklist

| Test | Command | Expected Result | Status |
|---|---|---|---|
| Serial console | Boot board | Login prompt visible | Pending |
| Kernel boot | `uname -a` | Kernel version shown | Pending |
| Root filesystem | `df -h` | Rootfs mounted | Pending |
| Ethernet | `ip addr`, `ping` | IP address and ping success | Pending |
| USB | `lsusb`, `dmesg` | USB device detected | Pending |
| Storage | `lsblk`, `df -h` | SD/eMMC visible | Pending |
| GPIO | `gpioinfo` | GPIO chips visible | Pending |
| Device tree | `/proc/device-tree/model` | Correct board model | Pending |
| Kernel logs | `dmesg` | No critical boot errors | Pending |

---

## 26. Expected Deliverables

The task is complete when the following are available:

### Build Artifacts

Generated under:

```text
tmp/deploy/images/<machine>/
```

Required artifacts:

- Bootloader
- Kernel image
- Device tree blob
- Root filesystem
- Bootable SD/eMMC image

### Documentation

Required documentation files:

```text
docs/v2n/yocto-build.md
docs/v2n/flashing.md
docs/v2n/board-bringup.md
docs/v2n/validation-checklist.md
docs/v2n/known-issues.md
```

### Logs

Required validation logs:

```text
logs/build/
logs/boot/
logs/validation/
```

Minimum required files:

```text
build-log.txt
v2n-first-boot.log
network-test.txt
usb-test.txt
storage-test.txt
gpio-test.txt
dmesg.txt
```

---

## 27. Acceptance Criteria

This task is accepted when:

- The V2N board boots successfully into Linux
- Kernel and root filesystem are built from source using Yocto
- Serial console login is functional
- Ethernet connectivity is verified
- Bootable SD/eMMC image is generated
- Basic peripherals are validated
- Another developer can repeat the build using this documentation
- All known issues and workarounds are documented
- Git repository structure is ready for future SDK customization

---

## 28. Known Issues Template

Use the following format when documenting issues:

```markdown
## Issue: <short issue title>

### Environment

- Host OS:
- WSL/native:
- Renesas SDK version:
- Yocto branch:
- MACHINE:
- Image recipe:

### Symptom

Describe the error message or board behavior.

### Root Cause

Explain the likely cause.

### Workaround

Document the exact workaround.

### Status

Open / Fixed / Workaround available

### Owner

Engineer name

### Date

YYYY-MM-DD
```

---

## 29. Suggested Git Workflow

Create a feature branch:

```bash
git checkout -b bringup/v2n-yocto-linux
```

Add documentation and scripts:

```bash
git add README.md docs/ scripts/ meta-alp/
```

Commit changes:

```bash
git commit -m "Add V2N Yocto Linux build and bring-up documentation"
```

Push branch:

```bash
git push origin bringup/v2n-yocto-linux
```

Create a pull request with the title:

```text
V2N Yocto Linux Baseline Bring-Up
```

---

## 30. Definition of Done

The Yocto Linux baseline task is done when:

```text
A clean Yocto build for the Renesas RZ/V2N Dev Board is reproducible,
the generated Linux image boots on real hardware,
serial console and Ethernet are verified,
basic peripherals are tested,
and the complete build/deployment process is documented for ALP developers.
```
