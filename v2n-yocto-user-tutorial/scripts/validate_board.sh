#!/usr/bin/env sh

OUT_DIR="/root/v2n-validation"
DATE="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo unknown-date)"

mkdir -p "$OUT_DIR"

echo "============================================================"
echo " V2N Yocto Linux Board Validation"
echo "============================================================"
echo "Saving logs to: $OUT_DIR"
echo

run_cmd() {
  NAME="$1"
  shift
  echo "[TEST] $NAME"
  {
    echo "# $NAME"
    echo "# Command: $*"
    echo "# Date: $DATE"
    echo
    "$@" 2>&1
  } > "$OUT_DIR/$NAME.txt"
}

run_shell() {
  NAME="$1"
  CMD="$2"
  echo "[TEST] $NAME"
  {
    echo "# $NAME"
    echo "# Command: $CMD"
    echo "# Date: $DATE"
    echo
    sh -c "$CMD" 2>&1
  } > "$OUT_DIR/$NAME.txt"
}

run_cmd "kernel" uname -a
run_shell "os-release" "cat /etc/os-release || true"
run_shell "cpuinfo" "cat /proc/cpuinfo || true"
run_cmd "memory" free -h
run_cmd "storage-df" df -h
run_shell "storage-lsblk" "lsblk || true"
run_shell "cmdline" "cat /proc/cmdline || true"
run_shell "device-tree-model" "cat /proc/device-tree/model || true"
run_shell "device-tree-compatible" "tr '\000' '\n' < /proc/device-tree/compatible || true"
run_cmd "network-ip" ip addr
run_shell "network-route" "ip route || true"
run_shell "ping-ip" "ping -c 4 8.8.8.8 || true"
run_shell "ping-dns" "ping -c 4 google.com || true"
run_shell "usb-lsusb" "lsusb || true"
run_shell "usb-lsblk" "lsblk || true"
run_shell "gpio-devices" "ls /dev/gpiochip* 2>/dev/null || true"
run_shell "gpioinfo" "gpioinfo 2>/dev/null || true"
run_shell "dmesg" "dmesg || true"
run_shell "dmesg-errors" "dmesg | grep -i -E 'error|fail|warn|panic|oops' || true"
run_shell "dmesg-ethernet" "dmesg | grep -i -E 'eth|ethernet|phy' || true"
run_shell "dmesg-usb" "dmesg | grep -i usb || true"
run_shell "dmesg-mmc" "dmesg | grep -i -E 'mmc|sdhci|sd card' || true"
run_shell "dmesg-renesas" "dmesg | grep -i renesas || true"
run_shell "systemd-failed" "systemctl --failed 2>/dev/null || true"

REPORT="$OUT_DIR/validation-summary.md"

cat > "$REPORT" <<EOF
# V2N Yocto Linux Validation Summary

## Board Information

- Test date: $DATE
- Hostname: $(hostname 2>/dev/null || echo unknown)
- Kernel: $(uname -a 2>/dev/null || echo unknown)

## Manual Result Checklist

| Test | Expected Result | Result |
|---|---|---|
| Serial console | Login prompt visible | Manual check required |
| Login | Shell prompt appears | Manual check required |
| Kernel | Linux kernel version shown | See kernel.txt |
| OS | Yocto/Poky information shown | See os-release.txt |
| CPU | CPU information shown | See cpuinfo.txt |
| Memory | Memory information shown | See memory.txt |
| Storage | Root filesystem and boot media visible | See storage-df.txt and storage-lsblk.txt |
| Device tree | Board model shown | See device-tree-model.txt |
| Ethernet | Ethernet interface visible | See network-ip.txt |
| IP ping | Ping to 8.8.8.8 successful | See ping-ip.txt |
| DNS ping | Ping to google.com successful | See ping-dns.txt |
| USB | USB device detected | See usb-lsusb.txt and usb-lsblk.txt |
| GPIO | GPIO devices visible | See gpio-devices.txt |
| Kernel logs | No critical errors | See dmesg-errors.txt |

## Log Directory

All logs are stored in:

\`\`\`text
$OUT_DIR
\`\`\`

EOF

echo
echo "Validation complete."
echo "Summary report:"
echo "  $REPORT"
echo
echo "Create archive with:"
echo "  tar -czf /root/v2n-validation.tar.gz /root/v2n-validation"
