# Installation on MSI Pulse 15 (x86_64)

## Step 1: Prepare the USB installer

Download the NixOS minimal ISO from https://nixos.org/download and write it to a USB drive:

```bash
# On Linux (adjust device name — use lsblk to find it)
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Step 2: Prepare Windows for dual-boot

Before installing NixOS alongside Windows 11:

1. **Disable BitLocker** — Settings > Privacy & Security > Device encryption > Turn off
2. **Shrink the Windows partition** — Disk Management > right-click the main partition > Shrink Volume. Free up at least 100 GB.
3. **Disable Secure Boot** — Enter BIOS (usually Del or F2 at boot) > Security > Secure Boot > Disabled
4. **Disable Fast Startup** — Control Panel > Power Options > Choose what the power buttons do > Turn off fast startup

Skip this step if doing a clean install (no Windows).

## Step 3: Boot from USB

1. Insert the USB drive and restart the laptop
2. Press F11 (or Del) at boot to open the boot menu
3. Select the USB drive
4. NixOS installer will boot to a root shell

## Step 4: Partition and mount drives

**Option A: Dual-boot alongside Windows**

Create a root partition on the free space. Reuse the existing Windows EFI partition.

| Partition | Size     | Type  | Mount    |
|-----------|----------|-------|----------|
| EFI       | existing | vfat  | /boot    |
| Root      | rest     | ext4  | /        |

```bash
# Format only the new root partition (adjust device name)
mkfs.ext4 /dev/nvme0n1pX

# Mount
mount /dev/nvme0n1pX /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot    # existing EFI partition
```

**Option B: Clean install on a new drive**

| Partition | Size   | Type  | Mount    |
|-----------|--------|-------|----------|
| EFI       | 512 MB | vfat  | /boot    |
| Root      | rest   | ext4  | /        |

```bash
# Partition (adjust device name)
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart root ext4 512MiB 100%

# Format
mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

# Mount
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

## Step 5: Connect to WiFi

```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YourSSID"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit
```

Or use `nmtui` if NetworkManager is available on the installer.

## Step 6: Clone this repo

```bash
nix-shell -p git
git clone https://github.com/YannickHerrero/nixos-config /mnt/etc/nixos
```

## Step 7: Generate hardware configuration

```bash
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/pulse15/hardware-configuration.nix
```

## Step 8: Install

```bash
nixos-install --flake /mnt/etc/nixos#pulse15
```

Set the root password when prompted, then reboot.

## Step 9: Post-install setup

After rebooting, log in as root and set the user password:

```bash
passwd sovereign
```

Log out and log back in as `sovereign`. dwm should start automatically.
