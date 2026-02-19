# st

Custom build of [st](https://st.suckless.org/) — simple terminal.

## Applied patches

- **xresources** — Reads terminal colors (0-15), foreground, background, and cursor color from `~/.Xresources` at startup. Resources: `st.color0`–`st.color15`, `st.foreground`, `st.background`, `st.cursorColor`.
