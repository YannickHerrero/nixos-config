# Installation on MacBook Air M2 (Apple Silicon)

## Prerequisites

- macOS with the [Asahi Linux installer](https://asahilinux.org/) already run to set up m1n1 + U-Boot (this is done when installing Asahi/omarchy)
- At least 250 GB of unallocated space on the internal NVMe (shrink from macOS Disk Utility before running Asahi installer, or use space freed from an existing Asahi install)

## Step 1: Get the NixOS aarch64 installer

Download the NixOS minimal ISO (aarch64) from https://nixos.org/download (select "aarch64" under the minimal ISO section).

Write it to a USB drive:

```bash
# On Linux or macOS (adjust device name)
sudo dd if=nixos-minimal-*-aarch64-linux.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Alternatively, if you already have an Asahi Linux installation, you can use it to write the USB or even install NixOS directly from there.

## Step 2: Boot from USB

1. Shut down the MacBook Air completely
2. Press and hold the power button until "Loading startup options" appears
3. Select the USB drive from the boot menu
4. If using U-Boot: it should chainload the NixOS installer from USB

## Step 3: Connect to WiFi

The NixOS aarch64 minimal ISO may not have Apple Silicon WiFi firmware. If WiFi doesn't work from the installer, use a USB Ethernet adapter or USB tethering from a phone.

If WiFi works:

```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YourSSID"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit
```

## Step 4: Partition the free space

Identify the unallocated space (use `lsblk` to see the disk layout). Create an EFI partition and a root partition:

```bash
# Find the NVMe device (usually /dev/nvme0n1)
lsblk

# Create partitions in the free space (adjust partition numbers)
# DO NOT touch existing macOS or Asahi partitions
parted /dev/nvme0n1 -- mkpart ESP fat32 START END    # 512 MB for EFI
parted /dev/nvme0n1 -- set N esp on
parted /dev/nvme0n1 -- mkpart root ext4 END 100%     # rest for root

# Format
mkfs.fat -F 32 /dev/nvme0n1pN      # EFI partition
mkfs.ext4 /dev/nvme0n1pM            # root partition

# Mount
mount /dev/nvme0n1pM /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1pN /mnt/boot
```

Replace `START`, `END`, `N`, and `M` with the actual values from `parted print free`.

## Step 5: Clone this repo

```bash
nix-shell -p git
git clone https://github.com/YannickHerrero/nixos-config /mnt/etc/nixos
```

## Step 6: Generate hardware configuration

```bash
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/macbook-air/hardware-configuration.nix
```

## Step 7: Install

```bash
nixos-install --flake /mnt/etc/nixos#macbook-air --impure
```

The `--impure` flag is required for Apple Silicon firmware access.

Set the root password when prompted, then reboot.

## Step 8: Post-install setup

After rebooting, the boot chain is: m1n1 -> U-Boot -> systemd-boot -> NixOS.

Log in as root and set the user password:

```bash
passwd sovereign
```

Log out and log back in as `sovereign`. dwm should start automatically.

## Step 9: Verify hardware

```bash
# Check GPU acceleration
glxinfo | grep renderer
# Should show "Asahi" or similar

# Check WiFi
nmcli device status

# Check audio
wpctl status

# Check Bluetooth
bluetoothctl show
```
