# Windows Setup

## Requirements

### PowerShell 7

Install PowerShell 7 using the official `.msi` installer from Microsoft.

> Depending on your system configuration, `winget` may install the Microsoft Store version instead, which can lead to:

Download the latest `.msi` release from:

https://github.com/PowerShell/PowerShell/releases

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

Install Windows Terminal using `winget`:

---

### Oh My Posh

Install Oh My Posh using `winget`:

---

### Neovim

Install Neovim using `winget`:

$env:EDITOR = "nvim"

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
- `font-firacode-nerd` — Nerd Font used by the terminal prompt and icons
- `ghostty` — terminal emulator
- `fzf` — fuzzy finder for shell navigation and history
- `zoxide` — smarter `cd` replacement

Install everything with:

```bash
sudo eopkg install zsh git vim font-firacode-nerd ghostty fzf zoxide
```

Set Zsh as the default shell:
```
chsh -s /usr/bin/zsh
```
Then reboot.

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

### Vim default editor

```
for type in \
    text/plain \
    text/x-python \
    text/x-script.python \
    text/x-shellscript \
    text/x-c \
    text/x-c++ \
    text/x-java \
    text/x-rust \
    text/x-go \
    text/x-lua \
    text/x-perl \
    text/x-ruby \
    text/x-php \
    text/x-julia \
    text/x-tex \
    text/markdown \
    text/x-yaml \
    application/x-yaml \
    application/json \
    application/xml
do
    xdg-mime default vim-terminal.desktop "$type"
done
```
command to set default type to be open with ```vim```


## Additional
Add `Hedron` repository to `eopkg`
```
sudo eopkg ar Hedron  https://hedron.friesischscott.de/eopkg-index.xml.xz
```
### zotero, seafile, mattermost, webex, juliaup, vscode
All available via `eopkg`

### keepassxc
enable `Browser Integration` in `Tool/settings`

### dconfig-editor
fix ```Ctrl+Alt+T``` shorcut for Ghostty

### Resilio Sync

Install compatibility package

```bash
sudo eopkg it libxcrypt-compat
```

---

Download the correct `.tar.gz` package for your architecture from the official page:

https://www.resilio.com/sync/download/

---

Extract the archive
```bash
tar -xf resilio-sync_x64.tar.gz
```

---

Move Resilio Sync to a permanent location

```bash
mkdir -p ~/.local/share
mv rslsync ~/.local/share/resilio-sync
```

---

Create the systemd user service
```bash
mkdir -p ~/.config/systemd/user
```
Create the service file:
```bash
nano ~/.config/systemd/user/resilio-sync.service
```

Paste:

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

Replace:
```text
YOUR_USERNAME
```
with your actual Linux username.

---

Reload systemd

```bash
systemctl --user daemon-reload
```

---

Enable autostart

```bash
systemctl --user enable resilio-sync.service
```

---

Start Resilio Sync

```bash
systemctl --user start resilio-sync.service
```

---

Enable lingering. This allows the user service to start automatically after reboot/login.
```bash
sudo loginctl enable-linger YOUR_USERNAME
```

---

The Resilio Sync WebUI will be available at:

```text
http://localhost:8888
```

---

Personal setup notes

- Create identity using the existing `.bst` backup file
- Link the new device to the existing Resilio Sync network
  
