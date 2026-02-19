# NixOS Configuration

Fully reproducible NixOS configuration with suckless tools (dwm, st, dmenu) as the desktop environment and home-manager for user-level configuration. Supports multiple hosts including x86_64 (MSI Pulse 15) and aarch64 Apple Silicon (MacBook Air M2).

## What's included

- **NixOS** with flakes (nixos-unstable channel)
- **Suckless tools**: dwm, st, dmenu — built from vendored source with patches (Xresources, fibonacci/dwindle layout)
- **Home Manager**: zsh, tmux, neovim, oh-my-posh, git (with delta), mpv, pywal theming
- **Modules**: PipeWire audio, Bluetooth, NetworkManager, fonts, locale (fr_FR)
- **pulse15**: Intel VA-API graphics, TLP power management, GRUB dual-boot with Windows
- **macbook-air**: Apple Silicon GPU (Asahi), systemd-boot, nixos-apple-silicon integration

## Repository structure

```
nixos-config/
├── flake.nix                  # Flake entry point
├── hosts/
│   ├── pulse15/               # MSI Pulse 15 (x86_64)
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── macbook-air/           # MacBook Air M2 (aarch64)
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/                   # NixOS modules
│   ├── suckless.nix
│   ├── graphics.nix           # Intel-only (pulse15)
│   ├── audio.nix
│   ├── bluetooth.nix
│   ├── networking.nix
│   ├── locale.nix
│   ├── power.nix              # Intel-only (pulse15)
│   ├── fonts.nix
│   └── packages.nix
├── suckless/                  # Vendored suckless source
│   ├── dwm/
│   ├── st/
│   └── dmenu/
└── home/                      # Home Manager config
    ├── default.nix
    ├── shell.nix
    ├── git.nix
    ├── neovim.nix
    ├── tmux.nix
    ├── ohmyposh.nix
    ├── theming.nix
    └── mpv.nix
```

## Installation on MSI Pulse 15 (x86_64)

### Step 1: Prepare the USB installer

Download the NixOS minimal ISO from https://nixos.org/download and write it to a USB drive:

```bash
# On Linux (adjust device name — use lsblk to find it)
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### Step 2: Prepare Windows for dual-boot

Before installing NixOS alongside Windows 11:

1. **Disable BitLocker** — Settings > Privacy & Security > Device encryption > Turn off
2. **Shrink the Windows partition** — Disk Management > right-click the main partition > Shrink Volume. Free up at least 100 GB.
3. **Disable Secure Boot** — Enter BIOS (usually Del or F2 at boot) > Security > Secure Boot > Disabled
4. **Disable Fast Startup** — Control Panel > Power Options > Choose what the power buttons do > Turn off fast startup

Skip this step if doing a clean install (no Windows).

### Step 3: Boot from USB

1. Insert the USB drive and restart the laptop
2. Press F11 (or Del) at boot to open the boot menu
3. Select the USB drive
4. NixOS installer will boot to a root shell

### Step 4: Partition and mount drives

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

### Step 5: Connect to WiFi

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

### Step 6: Clone this repo

```bash
nix-shell -p git
git clone https://github.com/YannickHerrero/nixos-config /mnt/etc/nixos
```

### Step 7: Generate hardware configuration

```bash
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/pulse15/hardware-configuration.nix
```

### Step 8: Install

```bash
nixos-install --flake /mnt/etc/nixos#pulse15
```

Set the root password when prompted, then reboot.

### Step 9: Post-install setup

After rebooting, log in as root and set the user password:

```bash
passwd sovereign
```

Log out and log back in as `sovereign`. dwm should start automatically.

## Installation on MacBook Air M2 (Apple Silicon)

### Prerequisites

- macOS with the [Asahi Linux installer](https://asahilinux.org/) already run to set up m1n1 + U-Boot (this is done when installing Asahi/omarchy)
- At least 250 GB of unallocated space on the internal NVMe (shrink from macOS Disk Utility before running Asahi installer, or use space freed from an existing Asahi install)

### Step 1: Get the NixOS aarch64 installer

Download the NixOS minimal ISO (aarch64) from https://nixos.org/download (select "aarch64" under the minimal ISO section).

Write it to a USB drive:

```bash
# On Linux or macOS (adjust device name)
sudo dd if=nixos-minimal-*-aarch64-linux.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Alternatively, if you already have an Asahi Linux installation, you can use it to write the USB or even install NixOS directly from there.

### Step 2: Boot from USB

1. Shut down the MacBook Air completely
2. Press and hold the power button until "Loading startup options" appears
3. Select the USB drive from the boot menu
4. If using U-Boot: it should chainload the NixOS installer from USB

### Step 3: Connect to WiFi

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

### Step 4: Partition the free space

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

### Step 5: Clone this repo

```bash
nix-shell -p git
git clone https://github.com/YannickHerrero/nixos-config /mnt/etc/nixos
```

### Step 6: Generate hardware configuration

```bash
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/macbook-air/hardware-configuration.nix
```

### Step 7: Install

```bash
nixos-install --flake /mnt/etc/nixos#macbook-air --impure
```

The `--impure` flag is required for Apple Silicon firmware access.

Set the root password when prompted, then reboot.

### Step 8: Post-install setup

After rebooting, the boot chain is: m1n1 -> U-Boot -> systemd-boot -> NixOS.

Log in as root and set the user password:

```bash
passwd sovereign
```

Log out and log back in as `sovereign`. dwm should start automatically.

### Step 9: Verify hardware

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

## Daily usage

After making configuration changes, rebuild the system:

```bash
# On pulse15
sudo nixos-rebuild switch --flake /etc/nixos#pulse15

# On macbook-air
sudo nixos-rebuild switch --flake /etc/nixos#macbook-air --impure
```

Or use the shell alias (auto-detects the current host):

```bash
rebuild
```

## Adding a new host

1. Create a new directory under `hosts/`, e.g. `hosts/newmachine/`
2. Add `configuration.nix` importing the modules you need
3. Generate `hardware-configuration.nix` on the target machine
4. Add a new entry in `flake.nix` under `nixosConfigurations`:

```nix
nixosConfigurations.newmachine = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hosts/newmachine/configuration.nix
    home-manager.nixosModules.home-manager
  ];
};
```

5. Build with `nixos-rebuild switch --flake /etc/nixos#newmachine`

For Apple Silicon hosts, you also need the `nixos-apple-silicon` flake input and must include `nixos-apple-silicon.nixosModules.apple-silicon-support` in the modules list. See the `macbook-air` entry in `flake.nix` for reference.

## Customizing suckless tools

The suckless tools (dwm, st, dmenu) are built from the vendored source in `suckless/`. To customize them:

1. Edit the source directly (e.g. `suckless/dwm/config.def.h`)
2. To apply a patch: download the `.diff` file and apply it with `patch -p1 < patchfile.diff` from within the tool's directory
3. Rebuild the system — NixOS will recompile the tool from the modified source:

```bash
rebuild
```
