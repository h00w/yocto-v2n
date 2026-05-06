# V2N Yocto Linux Validation Checklist

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
