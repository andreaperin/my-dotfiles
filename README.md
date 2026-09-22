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

Use the official `.msi` from https://github.com/PowerShell/PowerShell/releases — `winget`
may install the Microsoft Store version instead.

---

### Python

Needed by `install.ps1` (dotbot is Python-based). winget versions these per minor release,
so check the current one rather than hardcoding:
```powershell
winget search Python.Python.3
winget install --id Python.Python.3.13   # substitute whatever version the search returned
```

---

### Git

Official installer from the Git website. Keep it minimal — skip the Git Bash shell
integrations, PowerShell is the shell here.

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

Set `$EDITOR` (used by `git commit`). Session-only; add to `$PROFILE` to persist:
```powershell
$env:EDITOR = "nvim"
```

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

Config at `nvim/linux` → `~/.config/nvim` (via `nvim.conf.yaml`). Keymap/feature reference:
`nvim/linux/CHEATSHEET.md`. Below is what it needs beyond Neovim itself on a fresh machine.

Requires Neovim **≥ 0.12** (tested on 0.12.5).

### Julia (the language itself)

Everything Julia-specific (LSP, Runic, `<leader>bf`/`<leader>bv`, snippets) assumes `julia`
is on `PATH`. Install via **juliaup**:
```bash
sudo eopkg install juliaup
```
Without a `juliaup` package: `curl -fsSL https://install.julialang.org | sh`.

### Core CLI tools

```bash
sudo eopkg install tree-sitter-cli
```
Required by `nvim-treesitter` to compile parsers. Also needs a C compiler — check with
`command -v cc`.

```bash
sudo eopkg install ripgrep fd
```
Required by `mini.pick` for `<leader>ff` (find files) and `<leader>fg` (live grep).

`git` and `curl` are both needed at runtime — `git` by `vim.pack`, `mini.git`/`mini.diff`
and LazyGit; `curl` by `vim.pack` and the Typst/Markdown preview plugins, which download
their own binaries on first use. Normally already installed.

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
No standalone `typst` CLI needed — `typst-preview.nvim` downloads its own compiler binary,
and only lists `curl` as a dependency.

**Julia** — `LanguageServer.jl` in its own environment; not auto-installed:
```bash
julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'
```

Both `~/.local/bin` and `~/.julia/bin` (see Runic below) need to be on `PATH`.

### Julia tooling

**Runic** (Julia formatter) — must be installed from the base environment, i.e. a directory
with no active `Project.toml`, so it lands in the shared app registry:
```bash
cd ~ && julia -e 'using Pkg; Pkg.Apps.add("Runic")'
```
Installs to `~/.julia/bin/runic`; `~/.julia/bin` must be on `PATH` (set in
`~/.config/zsh/.zsh_paths`). That file is sourced from `.zshrc`, so it only applies to
*interactive* shells — verify `executable('runic')` from inside a running Neovim, not just
with `command -v`.

### LaTeX

TeX Live (`pdflatex`, `latexmk`) is assumed already installed.

**`latexindent`** — bundled with TeX Live, but needs these Perl modules to run:
```bash
sudo eopkg install perl-yaml-tiny perl-file-homedir
```

**Zathura** (PDF viewer, for `vimtex` forward/inverse search). `zathura-mupdf` pulls in the
`zathura` base package; without a backend plugin zathura cannot open PDFs at all:
```bash
sudo eopkg install zathura-mupdf
```
Inverse search needs no setup outside Neovim — vimtex passes the editor command to zathura
itself. See `nvim/linux/CHEATSHEET.md`'s LaTeX section.

### AI Assistant (Neovim)

The `99` plugin (`<leader>9*`) shells out to a CLI AI agent. Only Claude is set up;
other providers (`<leader>9p`) need their own CLI installed.

**Claude Code CLI** — official native installer, not `eopkg` or npm:
```bash
curl -fsSL https://claude.ai/install.sh | bash
```
Installs to `~/.local/share/claude/versions/`, symlinked from `~/.local/bin/claude`.

**Note**: the Claude provider always runs `claude --dangerously-skip-permissions`,
hardcoded in `99`'s source. See `nvim/linux/CHEATSHEET.md`'s "AI Assistant" section.

### Git tooling (Neovim)

```bash
sudo eopkg install lazygit
```

### Fonts (Neovim)

```bash
sudo eopkg install font-firacode-nerd
```
Required for `mini.icons`' glyphs and the statusline's icons/separators. Any Nerd Font
works; the terminal emulator has to be set to use it.

## Claude Code tooling

`claude.conf.yaml` links an executable into `~/.local/bin` instead of a config file.

```bash
./install claude.conf.yaml
```

- `claude/claude-session` — list, rename, open, remove and restore Claude Code session
  transcripts (`~/.claude/projects/*.jsonl`). Removals go to `~/.claude/.session-trash`
  and can be undone. Run with no arguments for usage.

Needs Python 3 and `~/.local/bin` on `PATH` (added by the SolusOS system profile, not by
`zsh/.zsh_paths`). The manifest sets `force: true` because the destination is normally a
real file, which dotbot won't overwrite otherwise.

## Recommended Modules
### Dashboard
Install dashboard utilities:

```bash
sudo eopkg install fastfetch cava
```

- `fastfetch` — system information dashboard
- `cava` — terminal audio visualizer

#### cbonsai

Terminal bonsai tree generator — https://gitlab.com/jallbrit/cbonsai

```bash
sudo eopkg install make ncurses-devel
sudo eopkg install -c system.devel
```

Build:

```bash
git clone https://gitlab.com/jallbrit/cbonsai
cd cbonsai
make
sudo make install
```

#### wmctrl

CLI for X11-compatible window managers — https://github.com/Conservatory/wmctrl

```bash
sudo eopkg install libx11-devel libxmu-devel glib2-devel
sudo eopkg install -c system.devel
```

Build:

```bash
git clone https://github.com/Conservatory/wmctrl.git
cd wmctrl
./configure
make
sudo make install
```

## Personal Notes (Author)

Personal setup steps for this author's own machines, not general bootstrap instructions.

**Extra `eopkg` repository** (needed for some of the apps below):
```bash
sudo eopkg ar Hedron https://hedron.friesischscott.de/eopkg-index.xml.xz
```

**Apps available directly via `eopkg`**: `zotero`, `seafile`, `mattermost`, `webex`, `vscode`.

**KeePassXC**: enable `Browser Integration` in `Tools → Settings`.

**dconf-editor**: used to fix the `Ctrl+Alt+T` shortcut for Ghostty.

### Noctalia Greeter

`noctalia-greeter` (Hedron repo above) is a greetd login screen matching Noctalia Shell.
Not dotbot-managed — it lives under `/etc` and `/var/lib`.

```bash
sudo eopkg install noctalia-greeter
```

1. **Seed greetd's config into `/etc`.** Solus is stateless: vendor defaults live under
   `/usr/share/defaults/`, `/etc` holds the overrides
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
libpam falls back to `/usr/share/defaults/etc/pam.d/`, but greetd pre-checks
   `/etc/pam.d/` and `/usr/lib/pam.d/` *only* and exits before PAM is consulted. Symptom if
   skipped: **black screen after reboot**, greetd restart-looping (`error: PAM 'greetd'
   service missing`, then `start-limit-hit`) — see `journalctl -b -1 -u greetd`. The copied
   file needs no edits.

3. **Create the greeter's state files** — `greeter.toml` and `sync.toml` under
   `/var/lib/noctalia-greeter`, owned by `greeter`. Run this *after* step 1, since it reads
   `/etc/greetd/config.toml` to resolve the account:
   ```bash
   sudo GREETER_USER=greeter /usr/bin/noctalia-greeter-apply-appearance --setup-system
   ```
Don't use `/usr/share/noctalia-greeter/setup_greeter_system.sh` — it also runs a PAM
   patch step that appends a duplicate `pam_systemd` line to the file from step 2.

4. **Take over from LightDM**, then reboot:
   ```bash
   sudo systemctl disable lightdm
   sudo systemctl enable greetd
   ```
`enable` writes `/etc/systemd/system/display-manager.service`, overriding the vendor
   symlink to `lightdm.service` — verify with
   `readlink -f /etc/systemd/system/display-manager.service`. Don't `systemctl start greetd`
   from a graphical session; it wants VT 1.

**Recovery** — if the screen comes up black, Ctrl+Alt+F2 gives a TTY (greetd only takes
VT 1):
```bash
sudo systemctl disable greetd && sudo systemctl enable lightdm && sudo reboot
```

**Customizing**: `/var/lib/noctalia-greeter/greeter.toml` is the hand-edited one — edit
with `sudoedit` so it stays `greeter:greeter`. Its generated comments document every key.
`sync.toml` beside it is written by the greeter UI and appearance sync, so don't hand-edit
it; the power menu (`[session.power]`, `[[session.actions]]`) lives there only.

**Syncing the shell's theme to the greeter** — wallpaper, palette and monitor
layout/scales/transforms, from the desktop session (not from a TTY):
```bash
noctalia msg greeter-sync
```

Needs a polkit agent; noctalia's is off by default. Without one the sync dies at
authorization silently, logging only `Error creating textual authentication agent`. Enable
in `noctalia/config/20-shell.toml`, under `[shell]`:
```toml
polkit_agent = true
```

Automatic sync on every theme change, without a password prompt — same file:
```toml
[shell.greeter_sync]
auto_sync = true
```
```bash
noctalia msg config-reload
sudo /usr/bin/noctalia-greeter passwordless-sync enable <user>
```

`msg` answers `ok` as soon as the daemon accepts the command, so check the log. Grep
first and tail the *matches* — `tail | grep` misses it on a log this chatty:
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

4. Create the systemd user service at `~/.config/systemd/user/resilio-sync.service`,
   replacing `YOUR_USERNAME`:
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

6. Enable lingering so it starts after reboot:
   ```bash
   sudo loginctl enable-linger YOUR_USERNAME
   ```

7. The WebUI is then available at http://localhost:8888.

**Identity setup**: create the identity using the existing `.bst` backup file, then link the
new device to the existing Resilio Sync network.

