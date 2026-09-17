# How This Repo Works

This repo is managed with [dotbot](https://github.com/anishathalye/dotbot) (vendored as a
git submodule). Each tool has its own `<app>.conf.yaml` manifest (e.g. `git.conf.yaml`,
`nvim.conf.yaml`, `niri_desktop.yaml`) declaring which dotfiles get symlinked where.

**First time cloning this repo**, pull in the dotbot submodule too:
```bash
git clone --recurse-submodules git@github.com:andreaperin/my-dotfiles.git
# or, if already cloned without --recurse-submodules:
git submodule update --init --recursive
```

**Linux**: apply one tool at a time by running its config file:
```bash
./install <app>.conf.yaml   # e.g. ./install nvim.conf.yaml, ./install git.conf.yaml
```

**Windows**: `install.ps1` always applies the single `windows.conf.yaml` (everything for
that platform at once, not per-app like Linux) and needs Python on `PATH`:
```powershell
./install.ps1
```

# Table of Contents

- [Windows Setup](#windows-setup)
  - [Requirements](#requirements)
    - [Python](#python)
  - [Recommended PowerShell Modules](#recommended-powershell-modules)
- [Linux Setup (SolusOS)](#linux-setup-solusos)
  - [Prerequisites](#prerequisites)
  - [Neovim configuration](#neovim-configuration)
    - [Julia (the language itself)](#julia-the-language-itself)
    - [Core CLI tools](#core-cli-tools)
    - [LSP servers](#lsp-servers-none-of-these-auto-install)
    - [Julia tooling](#julia-tooling)
    - [LaTeX](#latex)
    - [AI Assistant (Neovim)](#ai-assistant-neovim)
    - [Git tooling (Neovim)](#git-tooling-neovim)
    - [Fonts (Neovim)](#fonts-neovim)
  - [Claude Code tooling](#claude-code-tooling)
  - [Recommended Modules](#recommended-modules)
  - [Personal Notes (Author)](#personal-notes-author)

# Windows Setup

## Requirements

### PowerShell 7

Install PowerShell 7 using the official `.msi` installer from Microsoft.

> Depending on your system configuration, `winget` may install the Microsoft Store version instead, which can lead to:

Download the latest `.msi` release from:

https://github.com/PowerShell/PowerShell/releases

---

### Python

Needed by `install.ps1` itself (dotbot is Python-based) — winget's Python packages are
versioned per-minor-release, so check for the current one instead of hardcoding a version
that'll go stale:
```powershell
winget search Python.Python.3
winget install --id Python.Python.3.13   # substitute whatever version the search returned
```

---

### Git

Install Git using the official installer from the Git website.

> The goal is to keep the installation minimal and avoid additional Git Bash integrations or shell components that are unnecessary for this setup.
>
During installation:

- keep the setup minimal
- avoid extra shell integrations if not needed
- use PowerShell as the main shell environment

---

### Windows Terminal

```powershell
winget install --id Microsoft.WindowsTerminal
```

---

### Oh My Posh

```powershell
winget install --id JanDeDobbeleer.OhMyPosh
```

---

### Neovim

```powershell
winget install --id Neovim.Neovim
```

Set it as the default `$EDITOR` (used by `git commit` and similar tools) — this only
applies to the current session:
```powershell
$env:EDITOR = "nvim"
```
To persist it across sessions, add that line to your PowerShell profile (`$PROFILE`).

---

## Recommended PowerShell Modules

### Terminal-Icons

```powershell
Install-Module -Name Terminal-Icons -Scope CurrentUser
```

### Nerd Font(s)

```powershell
oh-my-posh font install
```

# Linux Setup (SolusOS)

## Prerequisites

Before installing the dotfiles, make sure the following dependencies are installed on Solus.

### Required packages

- `zsh` — default shell
- `git` — clone and manage the dotfiles repository
- `vim` — terminal text editor
- `neovim` — main editor (see the Neovim section below for its own, more extensive
  dependency list)
- `font-firacode-nerd` — Nerd Font used by the terminal prompt and icons
- `ghostty` — terminal emulator
- `fzf` — fuzzy finder for shell navigation and history
- `zoxide` — smarter `cd` replacement

Install everything with:

```bash
sudo eopkg install zsh git vim neovim font-firacode-nerd ghostty fzf zoxide
```

Set Zsh as the default shell:
```
chsh -s /usr/bin/zsh
```
Then reboot.

## Neovim configuration

The Neovim config lives at `nvim/linux` (symlinked to `~/.config/nvim` via
`nvim.conf.yaml`) — a from-scratch setup. The full keymap/feature reference lives in
`nvim/linux/CHEATSHEET.md`. Everything below is what it needs beyond Neovim/`vim.pack`
itself to actually work on a fresh machine.

Neovim itself: **≥ 0.12** (built and tested on 0.12.5) — several things were specifically
adjusted to work on *stable* Neovim rather than nightly, so an older release may hit the
same class of issue again.

### Julia (the language itself)

Everything Julia-specific in the Neovim config — the LSP, Runic, `<leader>bf`/`<leader>bv`,
the Julia snippets — assumes `julia` is already on `PATH`, regardless of which Julia
project you're actually editing. Install via **juliaup** (the officially recommended
installer, manages multiple Julia versions) — packaged for Solus:
```bash
sudo eopkg install juliaup
```
(On another distro without a `juliaup` package, use the official installer instead:
`curl -fsSL https://install.julialang.org | sh`.)

### Core CLI tools

```bash
sudo eopkg install tree-sitter-cli
```
Required by `nvim-treesitter` (the new rewrite this config uses) to build/compile parsers.
Also needs a working **C compiler** (`gcc`/`cc`) — virtually always already present on a dev
machine, but worth checking (`command -v cc`).

```bash
sudo eopkg install ripgrep fd
```
Required by `mini.pick` for `<leader>ff` (find files) and `<leader>fg` (live grep).

`git` and `curl` — `git` is needed both by `vim.pack` itself (cloning plugins) and at
*runtime* by `mini.git`/`mini.diff` (sign-column markers, `<leader>go`, `:Git`) and
LazyGit itself; `curl` is needed by `vim.pack` and by `typst-preview.nvim`/
`markdown-preview.nvim` (both download their own pre-built preview binaries on first
use, with no separate Node.js/Deno runtime required to run the downloaded binary
itself). Practically always already present, not worth a dedicated install step.

### LSP servers (none of these auto-install)

**Lua** — precompiled binary, not packaged for Solus. Check
https://github.com/LuaLS/lua-language-server/releases for the latest version and adjust the
URL below:
```bash
mkdir -p ~/.local/share/lua-language-server
curl -L https://github.com/LuaLS/lua-language-server/releases/download/<VERSION>/lua-language-server-<VERSION>-linux-x64.tar.gz | tar xz -C ~/.local/share/lua-language-server
ln -sf ~/.local/share/lua-language-server/bin/lua-language-server ~/.local/bin/lua-language-server
```

**Typst** — precompiled binary (`tinymist`), the LSP. Check
https://github.com/Myriad-Dreamin/tinymist/releases for the latest `tinymist-linux-x64`
asset:
```bash
curl -L -o ~/.local/bin/tinymist https://github.com/Myriad-Dreamin/tinymist/releases/download/<VERSION>/tinymist-linux-x64
chmod +x ~/.local/bin/tinymist
```
No separate standalone `typst` CLI is needed — confirmed via `typst-preview.nvim`'s own
README, its only listed dependency is `curl` (it bundles/downloads its own compiler
binary on first use, same as `markdown-preview.nvim` does).

**Julia** — needs `LanguageServer.jl` installed into its own dedicated environment (NOT
auto-installed by `nvim-lspconfig`, despite some other LSP servers being self-installing):
```bash
julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'
```

Both `~/.local/bin` and `~/.julia/bin` (see Runic below) need to be on `PATH`.

### Julia tooling

**Runic** (the Julia code formatter) — `Pkg.Apps.add` installs it as a standalone global
app (not a dependency of whatever project you happen to be in), but it must be run from
the **base/default Julia environment** — i.e. from a directory with no active
`Project.toml` (not from inside any Julia project's directory), so it lands in the shared
app registry rather than getting tangled up with a project-specific environment:
```bash
cd ~ && julia -e 'using Pkg; Pkg.Apps.add("Runic")'
```
Installs to `~/.julia/bin/runic` — make sure `~/.julia/bin` is on `PATH` (this machine has
it via `~/.config/zsh/.zsh_paths`, sourced from `.zshrc` — **note**: `.zshrc`-sourced PATH
entries are only visible to *interactive* shells, so anything checking `executable('runic')`
non-interactively, including Neovim launched in odd ways, needs this confirmed working from
inside a real running Neovim session, not just a terminal `command -v` check).

### LaTeX

TeX Live itself (providing `pdflatex`, `latexmk`) is assumed already installed — the
Neovim config doesn't set it up, just uses it.

**`latexindent`** (LaTeX formatter, bundled with TeX Live but **not functional out of the
box** — missing Perl modules):
```bash
sudo eopkg install perl-yaml-tiny perl-file-homedir
```

**Okular** (PDF viewer, for `vimtex` forward/inverse search — Zathura is the other common
choice if preferred instead, also in Solus repos):
```bash
sudo eopkg install okular
```
Inverse search (Okular → jump back to Neovim) also needs a one-time **manual GUI setting**
in Okular itself — see `nvim/linux/CHEATSHEET.md`'s LaTeX section for the exact steps and
command.

### AI Assistant (Neovim)

The `99` plugin (`<leader>9*` keymaps) shells out to a CLI AI agent per invocation. Only
Claude is actually set up right now — switching to another provider at runtime
(`<leader>9p`) needs that provider's own CLI installed too.

**Claude Code CLI** (`claude`), via the official native installer (not `eopkg`, not npm):
```bash
curl -fsSL https://claude.ai/install.sh | bash
```
Installs to `~/.local/share/claude/versions/`, symlinked from `~/.local/bin/claude` — make
sure `~/.local/bin` is on `PATH` (already required above for the Lua LSP/Typst LSP too).

**Note**: the Claude provider always runs `claude --dangerously-skip-permissions` — this
is hardcoded in `99`'s own source, not a config option. See
`nvim/linux/CHEATSHEET.md`'s "AI Assistant" section for what that actually means before
using it.

### Git tooling (Neovim)

```bash
sudo eopkg install lazygit
```

### Fonts (Neovim)

```bash
sudo eopkg install font-firacode-nerd
```
A Nerd Font is required for `mini.icons`' glyphs (file-type icons in `mini.pick`/`mini.files`)
and the custom statusline's icons/separators. Any Nerd Font variant works, not specifically
FiraCode — this is just what's on this machine. Your terminal emulator also needs to be
configured to actually use it as its font.

## Claude Code tooling

`claude.conf.yaml` is the odd one out: instead of linking a config file, it links an
executable into `~/.local/bin`.

```bash
./install claude.conf.yaml
```

- `claude/claude-session` — lists, renames, opens, removes and restores Claude Code
  session transcripts (the `.jsonl` files under `~/.claude/projects/`). Removals go to
  `~/.claude/.session-trash`, so they can be undone. Run `claude-session` with no
  arguments for the full usage text.

Needs Python 3 (already a prerequisite for dotbot) and `~/.local/bin` on `PATH` — on
SolusOS the system profile adds it, so nothing in `zsh/.zsh_paths` does.

This manifest sets `force: true`, which the others don't: the script normally already
exists at the destination as a real file, and dotbot refuses to overwrite one without it.

## Recommended Modules
### Dashboard
Install dashboard utilities:

```bash
sudo eopkg install fastfetch cava
```

- `fastfetch` — system information dashboard
- `cava` — terminal audio visualizer

#### cbonsai

`cbonsai` is a terminal-based bonsai tree generator written in C using `ncurses`.

Repository:

```text
https://gitlab.com/jallbrit/cbonsai
```

Install required dependencies:

```bash
sudo eopkg install make ncurses-devel
sudo eopkg install -c system.devel
```

Clone and install:

```bash
git clone https://gitlab.com/jallbrit/cbonsai
cd cbonsai
make
sudo make install
```

#### wmctrl

`wmctrl` is a command-line utility to interact with X11-compatible window managers.

Repository:

```text
https://github.com/Conservatory/wmctrl
```

Install required dependencies:

```bash
sudo eopkg install libx11-devel libxmu-devel glib2-devel
sudo eopkg install -c system.devel
```

Clone and install:

```bash
git clone https://github.com/Conservatory/wmctrl.git
cd wmctrl
./configure
make
sudo make install
```

## Personal Notes (Author)

Miscellaneous personal setup steps for this author's own machines — not general bootstrap
instructions, kept here for reference when setting up a new one.

**Extra `eopkg` repository** (needed for some of the apps below):
```bash
sudo eopkg ar Hedron https://hedron.friesischscott.de/eopkg-index.xml.xz
```

**Apps available directly via `eopkg`**: `zotero`, `seafile`, `mattermost`, `webex`, `vscode`.

**KeePassXC**: enable `Browser Integration` in `Tools → Settings`.

**dconf-editor**: used to fix the `Ctrl+Alt+T` shortcut for Ghostty.

### Noctalia Greeter

`noctalia-greeter` (from the Hedron repo above) is a greetd login screen matching Noctalia
Shell. Nothing here is dotbot-managed — it all lives under `/etc` and `/var/lib`.

```bash
sudo eopkg install noctalia-greeter
```

1. **Seed greetd's config into `/etc`.** Solus is stateless: packages ship their vendor
   defaults under `/usr/share/defaults/`, and `/etc` holds the machine's overrides
   (https://help.getsol.us/docs/user/software/configuration_files/).
   ```bash
   sudo mkdir -p /etc/greetd
   sudo cp -a /usr/share/defaults/greetd/config.toml /etc/greetd/config.toml
   ```
   Then set `[default_session]` in the copy:
   ```toml
   [terminal]
   vt = 1

   [default_session]
   command = "/usr/bin/noctalia-greeter-session"
   user = "greeter"
   ```
   Append `-- --session Niri` to `command` to skip the session picker — the name has to
   match what `noctalia-greeter sessions` prints.

2. **Copy the PAM stack too.** Not optional, and not obvious:
   ```bash
   sudo mkdir -p /etc/pam.d
   sudo cp -a /usr/share/defaults/etc/pam.d/greetd /etc/pam.d/greetd
   ```
   libpam itself falls back to `/usr/share/defaults/etc/pam.d/` — which is why the whole
   system authenticates fine with no `/etc/pam.d` at all — but greetd pre-checks for its
   service file in `/etc/pam.d/` and `/usr/lib/pam.d/` *only*, and exits before PAM is ever
   consulted. Symptom if skipped: **black screen after reboot**, with greetd restart-looping
   (`error: PAM 'greetd' service missing`, then `start-limit-hit`) — visible via
   `journalctl -b -1 -u greetd`. The copied file needs no edits: it includes
   `system-local-login` → `system-login`, which already has `pam_systemd`.

3. **Create the greeter's state files** — `greeter.toml` and `sync.toml` under
   `/var/lib/noctalia-greeter`, owned by `greeter`. Run this *after* step 1, since it reads
   `/etc/greetd/config.toml` to resolve the account:
   ```bash
   sudo GREETER_USER=greeter /usr/bin/noctalia-greeter-apply-appearance --setup-system
   ```
   Don't use the package's own `/usr/share/noctalia-greeter/setup_greeter_system.sh` here:
   it wraps the same call but also runs a PAM patch step that, on Solus, appends a duplicate
   `pam_systemd` line to the file copied in step 2.

4. **Take over from LightDM**, then reboot:
   ```bash
   sudo systemctl disable lightdm
   sudo systemctl enable greetd
   ```
   `enable` writes `/etc/systemd/system/display-manager.service`, which overrides the vendor
   symlink `/usr/lib/systemd/system/display-manager.service` → `lightdm.service`. Verify with
   `readlink -f /etc/systemd/system/display-manager.service`. Don't `systemctl start greetd`
   from a running graphical session — it wants VT 1 and conflicts with `getty@tty1` while
   LightDM still holds the display.

**Recovery** — if the screen comes up black, Ctrl+Alt+F2 gives a TTY (greetd only takes
VT 1):
```bash
sudo systemctl disable greetd && sudo systemctl enable lightdm && sudo reboot
```

**Customizing**: `/var/lib/noctalia-greeter/greeter.toml` is the declarative, hand-edited
one — the greeter UI and appearance sync never write to it. Use `sudoedit` so it stays
`greeter:greeter`. Its generated comments document every key; the sections are
`[appearance]` (`scheme`, `theme_mode`, `password_style`, `hide_logo`,
`power_buttons_position`, `scheme_selector_position`, `corner_radius_scale`,
`font_family`), `[appearance.palette]`, `[appearance.wallpaper]`,
`[appearance.wallpapers.<connector>]` (connector names from `noctalia-greeter outputs`),
`[auth]`, `[keyboard]`, `[output]`, `[idle]`, `[cursor]`, `[session]` and `[user]`.

`sync.toml` in the same directory is the opposite — written by the greeter UI and by
appearance sync, so don't hand-edit it. The power menu (`[session.power]`,
`[[session.actions]]`) lives there and isn't settable in `greeter.toml`.

**Syncing the shell's theme to the greeter** — wallpaper, palette and monitor
layout/scales/transforms, from the desktop session (not from a TTY):
```bash
noctalia msg greeter-sync
```

This needs a polkit agent, and noctalia's is off by default — without one the sync dies at
authorization with no dialog and nothing on stdout, logging only `Error creating textual
authentication agent`. Enable it in `noctalia/config/20-shell.toml`, under `[shell]`:
```toml
polkit_agent = true
```

For automatic syncing on every theme change, plus no password prompt each time — same file,
as a table at the end:
```toml
[shell.greeter_sync]
auto_sync = true
```
```bash
noctalia msg config-reload
sudo /usr/bin/noctalia-greeter passwordless-sync enable <user>
```

`msg` answers `ok` as soon as the daemon accepts the command, so check the log, not the
terminal — grep first and tail the *matches*, since `tail | grep` misses it on a log this
chatty:
```bash
grep 'greeter-sync' ~/.cache/noctalia/noctalia.log | tail -8
```
Success ends in `synced shell appearance to greeter`.

### Resilio Sync

1. Install the compatibility package:
   ```bash
   sudo eopkg it libxcrypt-compat
   ```

2. Download the correct `.tar.gz` for your architecture from the official page:
   https://www.resilio.com/sync/download/

3. Extract it and move it to a permanent location:
   ```bash
   tar -xf resilio-sync_x64.tar.gz
   mkdir -p ~/.local/share
   mv rslsync ~/.local/share/resilio-sync
   ```

4. Create the systemd user service:
   ```bash
   mkdir -p ~/.config/systemd/user
   nano ~/.config/systemd/user/resilio-sync.service
   ```
   Paste (replacing `YOUR_USERNAME` with your actual Linux username):
   ```ini
   [Unit]
   Description=Resilio Sync Service (per-user)
   After=network.target

   [Service]
   Type=simple
   ExecStart=/home/YOUR_USERNAME/.local/share/resilio-sync/rslsync --nodaemon
   Restart=on-failure

   [Install]
   WantedBy=default.target
   ```

5. Reload systemd, enable, and start the service:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable resilio-sync.service
   systemctl --user start resilio-sync.service
   ```

6. Enable lingering, so the user service also starts automatically after reboot/login:
   ```bash
   sudo loginctl enable-linger YOUR_USERNAME
   ```

7. The WebUI is then available at http://localhost:8888.

**Identity setup**: create the identity using the existing `.bst` backup file, then link the
new device to the existing Resilio Sync network.

