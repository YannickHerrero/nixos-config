# dwm

Custom build of [dwm](https://dwm.suckless.org/) — dynamic window manager.

## Applied patches

- **xresources** — Reads colors and settings from `~/.Xresources` at startup. Supports live reload via `kill -USR1 $(pidof dwm)`. Resources: `dwm.color0` (normbg), `dwm.color8` (normborder), `dwm.foreground` (normfg), `dwm.color15` (selfg), `dwm.color4` (selbg/selborder), `dwm.borderpx`, `dwm.snap`, `dwm.showbar`, `dwm.topbar`, `dwm.nmaster`, `dwm.resizehints`, `dwm.mfact`.
