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
├── guide/                     # Installation guides
│   ├── pulse15.md
│   └── macbook-air.md
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

- [MSI Pulse 15 (x86_64)](guide/pulse15.md) — dual-boot with Windows or clean install
- [MacBook Air M2 (Apple Silicon)](guide/macbook-air.md) — requires Asahi m1n1 + U-Boot setup

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
