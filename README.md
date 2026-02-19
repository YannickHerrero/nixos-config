# NixOS Configuration

Fully reproducible NixOS configuration with suckless tools (dwm, st, dmenu) as the desktop environment and home-manager for user-level configuration. Dual-boots with Windows 11 via GRUB.

## What's included

- **NixOS** with flakes (nixos-unstable channel)
- **Suckless tools**: dwm, st, dmenu — built from vendored source with patches (Xresources, fibonacci/dwindle layout)
- **Home Manager**: zsh, tmux, neovim, oh-my-posh, git (with delta), mpv, pywal theming
- **Modules**: graphics (Intel VA-API), PipeWire audio, Bluetooth, NetworkManager, TLP power management, fonts, locale (fr_FR)

## Repository structure

```
nixos-config/
├── flake.nix                  # Flake entry point
├── hosts/pulse15/             # Host-specific config
│   ├── configuration.nix
│   └── hardware-configuration.nix
├── modules/                   # NixOS modules
│   ├── suckless.nix
│   ├── graphics.nix
│   ├── audio.nix
│   ├── bluetooth.nix
│   ├── networking.nix
│   ├── locale.nix
│   ├── power.nix
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

## Installation

Download the NixOS minimal ISO from https://nixos.org/download and write it to a USB drive. Boot from the USB.

### Option A: Dual-boot alongside Windows

#### 1. Prepare Windows

Before installing NixOS alongside Windows 11:

1. **Disable BitLocker** — Settings > Privacy & Security > Device encryption > Turn off
2. **Shrink the Windows partition** — Disk Management > right-click the main partition > Shrink Volume. Free up at least 100 GB.
3. **Disable Secure Boot** — Enter BIOS (usually Del or F2 at boot) > Security > Secure Boot > Disabled
4. **Disable Fast Startup** — Control Panel > Power Options > Choose what the power buttons do > Turn off fast startup

#### 2. Partition and mount drives

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

### Option B: Clean install on a new drive

#### 1. Partition and mount drives

Create an EFI partition and a root partition on the entire disk.

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

### Common steps (both options)

#### 1. Connect to WiFi

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

#### 2. Clone this repo

```bash
nix-shell -p git
git clone https://github.com/YannickHerrero/nixos-config /mnt/etc/nixos
```

#### 3. Generate hardware configuration

```bash
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/pulse15/hardware-configuration.nix
```

#### 4. Install

```bash
nixos-install --flake /mnt/etc/nixos#pulse15
```

Set the root password when prompted, then reboot.

After rebooting, log in and set the user password:

```bash
sudo passwd sovereign
```

## Daily usage

After making configuration changes, rebuild the system:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#pulse15
```

Or use the shell alias:

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

## Customizing suckless tools

The suckless tools (dwm, st, dmenu) are built from the vendored source in `suckless/`. To customize them:

1. Edit the source directly (e.g. `suckless/dwm/config.def.h`)
2. To apply a patch: download the `.diff` file and apply it with `patch -p1 < patchfile.diff` from within the tool's directory
3. Rebuild the system — NixOS will recompile the tool from the modified source:

```bash
rebuild
```
