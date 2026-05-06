# Serial Console Guide

Use these serial settings:

```text
115200 8N1
No flow control
```

## Linux

```bash
./scripts/open_serial_linux.sh /dev/ttyUSB0
```

## Windows

Use Tera Term, PuTTY, or MobaXterm.

Settings:

```text
Baud rate: 115200
Data bits: 8
Parity: None
Stop bits: 1
Flow control: None
```
