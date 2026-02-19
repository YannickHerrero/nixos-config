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

## Fresh installation

### 1. Prepare Windows

Before installing NixOS alongside Windows 11:

1. **Disable BitLocker** — Settings > Privacy & Security > Device encryption > Turn off
2. **Shrink the Windows partition** — Disk Management > right-click the main partition > Shrink Volume. Free up at least 100 GB.
3. **Disable Secure Boot** — Enter BIOS (usually Del or F2 at boot) > Security > Secure Boot > Disabled
4. **Disable Fast Startup** — Control Panel > Power Options > Choose what the power buttons do > Turn off fast startup

### 2. Boot the NixOS installer

Download the NixOS minimal ISO from https://nixos.org/download and write it to a USB drive. Boot from the USB.

### 3. Connect to WiFi

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

### 4. Partition and mount drives

Use `fdisk`, `parted`, or `cfdisk` to create partitions on the free space. Example layout:

| Partition | Size     | Type  | Mount    |
|-----------|----------|-------|----------|
| EFI       | existing | vfat  | /boot    |
| Root      | rest     | ext4  | /        |

```bash
# Format (adjust device names)
mkfs.ext4 /dev/nvme0n1pX

# Mount
mount /dev/nvme0n1pX /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot    # existing EFI partition
```

### 5. Clone this repo

```bash
nix-shell -p git
git clone https://github.com/YannickHerrero/nixos-config /mnt/etc/nixos
```

### 6. Generate hardware configuration

```bash
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/pulse15/hardware-configuration.nix
```

### 7. Install

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
