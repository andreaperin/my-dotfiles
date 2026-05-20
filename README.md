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

# Solus Setup

## Requirements
## Recommended Modules
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
