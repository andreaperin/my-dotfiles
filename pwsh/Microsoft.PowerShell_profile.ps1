# ============================
# PowerShell Profile Setup
# ============================

# ------------------------------------------------------------
# Prompt (Oh My Posh)
# ------------------------------------------------------------
# Loads your custom Oh My Posh theme for a modern PowerShell prompt
$themePath = Join-Path "$HOME\themes" "custom.omp.json"
oh-my-posh init pwsh --config $themePath | Invoke-Expression


# ------------------------------------------------------------
# Core Enhancements
# ------------------------------------------------------------
# PSReadLine provides rich command-line editing and history
Import-Module PSReadLine | Out-Null
Set-PSReadlineOption -PredictionSource History
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Fancy icons in directory listings (like `ls --color`)
Import-Module Terminal-Icons | Out-Null

# ------------------------------------------------------------
# fzf (Fuzzy Finder) Integration
# ------------------------------------------------------------
# Provides fuzzy search for files, directories, and command history
if (Get-Command fzf.exe -ErrorAction SilentlyContinue) {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    # Keybindings:
    #   Ctrl+T → fuzzy-find files
    #   Ctrl+R → fuzzy-search command history
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                    -PSReadlineChordReverseHistory 'Ctrl+r'
}

# fzf environment configuration
$env:FZF_COMPLETION_TRIGGER='~~'
$env:FZF_DEFAULT_OPTS='--multi --height=80% --layout=reverse-list --border=double --info=inline'


# ------------------------------------------------------------
# zoxide (Smarter cd)
# ------------------------------------------------------------
# Tracks your most used directories and lets you jump quickly:
#   z <keyword>  → jump to best match
#   zi <keyword> → interactive fzf-based jump
Invoke-Expression -Command (zoxide init powershell | Out-String)

function zi {
    param([string]$query)
    zoxide query -i $query | fzf --height 80% --layout=reverse-list --border | % { Set-Location $_ }
}

# ------------------------------------------------------------
# Linux-style ls Aliases (PowerShell functions)
# ------------------------------------------------------------
# Mimic common Linux `ls` aliases with colorful, table-style output

# Equivalent to: ls --color=auto
function ls {
    param([string]$Path = ".")
    Get-ChildItem -Path $Path | Format-Table Mode, LastWriteTime, Length, Name
}

# Equivalent to: ls -lah (show all, human-readable)
function lsa {
    param([string]$Path = ".")
    Get-ChildItem -Force -Path $Path | Format-Table Mode, LastWriteTime, Length, Name
}

# Equivalent to: ls -lah (short alias)
function l {
    param([string]$Path = ".")
    Get-ChildItem -Force -Path $Path | Format-Table Mode, LastWriteTime, Length, Name
}

# Equivalent to: ls -lh (long list, human-readable)
function ll {
    param([string]$Path = ".")
    Get-ChildItem -Path $Path | Format-Table Mode, LastWriteTime, Length, Name
}

# Equivalent to: ls -lAh (all except . and ..)
function la {
    param([string]$Path = ".")
    Get-ChildItem -Force -Path $Path | Where-Object { $_.Name -notmatch '^\.\.?$' } |
        Format-Table Mode, LastWriteTime, Length, Name
}


# ------------------------------------------------------------
# Git Ignore Helper (gi)
# ------------------------------------------------------------
# Downloads .gitignore templates from gitignore.io
# Usage:
#   gi python,windows > .gitignore
#
# Removes PowerShell’s default `gi` alias (Get-Item) so we can override it
if (Test-Path Alias:gi) {
    Remove-Item Alias:gi -Force
}

function gi {
    param(
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$Templates
    )

    # Join multiple templates with commas, remove spaces
    $joined = ($Templates -join ",").Replace(" ", "")

    # Build the gitignore.io URL
    $url = "https://www.toptal.com/developers/gitignore/api/$joined"

    # Fetch and output the gitignore template
    Invoke-RestMethod -Uri $url
}

# ------------------------------------------------------------
# Reload Alias
# ------------------------------------------------------------
# Quickly reloads the profile and clears the screen
# Usage: reload
function reload {
    Clear-Host
    . $PROFILE
}

# ------------------------------------------------------------
# Update Alias (winget upgrade)
# ------------------------------------------------------------
# Updates all packages installed via winget
# Usage: update
function update {
    Write-Host "📦 Checking for updates..." -ForegroundColor Cyan
    winget upgrade --all --include-unknown

    Write-Host "🧹 Cleaning desktop shortcuts..." -ForegroundColor Yellow
    $desktops = @(
        [Environment]::GetFolderPath("Desktop"),                  # Current user Desktop
        [Environment]::GetFolderPath("CommonDesktopDirectory")    # Public Desktop (all users)
    )

    foreach ($desktop in $desktops) {
        if (Test-Path $desktop) {
            Get-ChildItem -Path $desktop -Filter *.lnk -File | Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host "✅ Updates applied and desktop cleaned." -ForegroundColor Green
}