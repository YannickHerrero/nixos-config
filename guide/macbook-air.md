# Installation on MacBook Air M2 (Apple Silicon)

This guide follows the [nixos-apple-silicon](https://github.com/nix-community/nixos-apple-silicon) UEFI standalone method, adapted for this flake-based config.

## Prerequisites

- A MacBook Air M2 running macOS 12.3 or later
- A USB flash drive (512 MB+)
- Access to a Linux machine (or VM) with Nix installed, to build the installer ISO
- At least 60 GB of free disk space on the internal NVMe for NixOS

> If you already have Asahi/omarchy installed, you still need to run the Asahi installer again to create a **separate** UEFI-only stub for NixOS. The existing Asahi stub belongs to omarchy.

## Step 1: Build the installer ISO

The standard NixOS aarch64 ISO lacks Apple Silicon kernel, drivers, and firmware. You must build a custom installer from the nixos-apple-silicon repo.

On a Linux machine (or an existing Asahi install):

```bash
git clone https://github.com/tpwrules/nixos-apple-silicon
cd nixos-apple-silicon
nix build --extra-experimental-features 'nix-command flakes' .#installer-bootstrap -o installer -j4 -L
```

Write the ISO to a USB drive:

```bash
sudo dd if=installer/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress
```

Replace `/dev/sdX` with your USB device (check with `lsblk`).

## Step 2: Set up the UEFI environment (from macOS)

Boot into macOS and run the Asahi installer:

```bash
curl https://alx.sh | sh
```

Follow the prompts:

1. Resize your macOS partition or use existing free space (minimum 20 GB for the NixOS root partition)
2. Select **"UEFI environment only"** when asked what to install
3. Name the new OS **"NixOS"**
4. Complete the installation — a stub partition (m1n1 + U-Boot) and an EFI partition are created automatically
5. When prompted, boot into the new stub from the startup disk picker
6. Follow the on-screen instructions to set **permissive security** in recovery mode
7. Shut down the MacBook

## Step 3: Boot the installer

1. Plug in the USB drive
2. Power on the MacBook — hold the power button until "Loading startup options" appears
3. Select the **NixOS** stub (not USB directly — U-Boot chainloads from USB)
4. U-Boot should automatically boot from USB. If it doesn't, interrupt autoboot and run `bootmenu` to select the USB device

Once booted into the installer:

```bash
sudo su
```

Optionally increase the console font size:

```bash
setfont ter-v32n
```

## Step 4: Connect to WiFi

The nixos-apple-silicon installer uses `iwd`:

```bash
iwctl
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect "YourSSID"
[iwd]# exit
```

## Step 5: Partition and mount

The Asahi installer already created the EFI partition. You only need to create a root partition in the remaining free space.

Create the root partition:

```bash
sgdisk /dev/nvme0n1 -n 0:0 -s
```

Verify the layout:

```bash
sgdisk /dev/nvme0n1 -p
```

Format the new partition (the last one, e.g. `/dev/nvme0n1p5` — check the output above):

```bash
mkfs.ext4 -L nixos /dev/nvme0n1pN
```

Replace `N` with the actual partition number from `sgdisk -p`.

Mount the partitions:

```bash
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-partuuid/$(cat /proc/device-tree/chosen/asahi,efi-system-partition) /mnt/boot
```

The device-tree path ensures you mount the correct Asahi-created EFI partition.

## Step 6: Clone this repo and generate hardware config

```bash
nix-shell -p git
git clone https://github.com/YannickHerrero/nixos-config /mnt/etc/nixos
```

Generate the hardware configuration:

```bash
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/macbook-air/hardware-configuration.nix
```

## Step 7: Copy peripheral firmware (recommended)

Copy the firmware from the boot partition so NixOS can access it offline (avoids needing `--impure` for firmware on future rebuilds):

```bash
mkdir -p /mnt/etc/nixos/firmware
cp /mnt/boot/asahi/{all_firmware.tar.gz,kernelcache*} /mnt/etc/nixos/firmware
```

If you use this, make sure your NixOS config includes:

```nix
hardware.asahi.peripheralFirmwareDirectory = ./firmware;
```

Otherwise, the default behavior extracts firmware automatically but requires `--impure`.

## Step 8: Install

Synchronize the system clock (TLS certificate validation will fail otherwise):

```bash
systemctl restart systemd-timesyncd
```

Run the installer:

```bash
nixos-install --flake /mnt/etc/nixos#macbook-air --impure
```

Set the root password when prompted, then reboot:

```bash
reboot
```

## Step 9: Post-install setup

The boot chain is: m1n1 → U-Boot → systemd-boot → NixOS.

Log in as root and set the user password:

```bash
passwd sovereign
```

Log out and log back in as `sovereign`.

## Step 10: Verify hardware

```bash
# GPU acceleration
glxinfo | grep renderer
# Should show "Asahi" or similar

# WiFi
nmcli device status

# Audio
wpctl status

# Bluetooth
bluetoothctl show
```
