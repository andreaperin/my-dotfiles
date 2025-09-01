# ============================================
# Winget Installation Script for Core Packages
# ============================================

$ErrorActionPreference = "Stop"

# Ensure script runs as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator!"
    exit
}

# List of packages to install via winget
$packages = @(
    @{ Id = "Microsoft.PowerShell"; Name = "PowerShell" },
    @{ Id = "Microsoft.PowerToys"; Name = "PowerToys" },
    @{ Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal" },
    @{ Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" },
    @{ Id = "Git.Git"; Name = "Git" },
    @{ Id = "junegunn.fzf"; Name = "fzf" },
    @{ Id = "ajeetdsouza.zoxide"; Name = "zoxide" },
    @{ Id = "Python.Python.3.11"; Name = "Python 3" }
)

# Function to check if a package is installed via winget
function Is-WingetInstalled {
    param([string]$Id)
    try {
        $pkg = winget list --id $Id -s winget | Select-String $Id
        return $pkg -ne $null
    } catch {
        return $false
    }
}

# Install or upgrade each package
foreach ($pkg in $packages) {
    Write-Host "Processing $($pkg.Name)..." -ForegroundColor Cyan

    if ($pkg.Id -eq "Microsoft.PowerShell") {
        # Always reinstall PowerShell via winget to ensure tracking
        Write-Host "Installing or updating PowerShell via winget..." -ForegroundColor Yellow
        winget install --id $pkg.Id --force --silent --accept-source-agreements --accept-package-agreements -h
    } elseif (-not (Is-WingetInstalled $pkg.Id)) {
        # Install only if not already installed
        Write-Host "Installing $($pkg.Name)..." -ForegroundColor Green
        winget install --id $pkg.Id --silent --accept-source-agreements --accept-package-agreements -h
    } else {
        Write-Host "$($pkg.Name) is already installed, skipping..." -ForegroundColor Gray
    }
}

Write-Host "✅ All packages processed." -ForegroundColor Green


# Install Fira Code Nerd Font via Oh My Posh
Write-Host "`nInstalling Fira Code Nerd Font via Oh My Posh..."
oh-my-posh font install FiraCode

# Install PowerShell modules
Write-Host "`nInstalling required PowerShell modules (PSReadLine, Terminal-Icons, PSFzf)..."

$modules = @("PSReadLine", "Terminal-Icons", "PSFzf")

foreach ($mod in $modules) {
    try {
        if (-not (Get-Module -ListAvailable -Name $mod)) {
            Install-Module -Name $mod -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Host "Installed module: $mod"
        } else {
            Write-Host "Module already installed: $mod"
        }
    } catch {
        Write-Warning "Failed to install module: $mod ($_ )"
    }
}

# Enable WSL and Virtual Machine Platform
Write-Host "`nEnabling WSL and Virtual Machine Platform..."
try {
    # Enable WSL optional feature
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop

    # Enable Virtual Machine Platform (required for WSL2)
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

    # Set WSL2 as default version
    wsl --set-default-version 2

    Write-Host "WSL and Virtual Machine Platform enabled."
} catch {
    Write-Warning "Failed to enable WSL: $_"
}

# -------------------------------
# Ensure zoxide folder is in User PATH
# -------------------------------
function Ensure-ZoxideInPath {
    $zoxideCmd = Get-Command zoxide -ErrorAction SilentlyContinue
    if (-not $zoxideCmd) {
        Write-Warning "zoxide.exe not found. Make sure it was installed via winget."
        return
    }
    $zoxideFolder = Split-Path $zoxideCmd.Source
    # Get current user PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $paths = $userPath -split ';' | ForEach-Object { $_.Trim() }

    if ($paths -contains $zoxideFolder) {
        Write-Host "zoxide folder is already in user PATH."
    } else {
        # Add folder permanently to user PATH
        $newUserPath = "$userPath;$zoxideFolder"
        [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
        Write-Host "Added $zoxideFolder to user PATH. You may need to restart PowerShell to apply."
    }
}
# Call the function after installing zoxide
Ensure-ZoxideInPath


# -------------------------------
# Create Symlinks with dotbot
# -------------------------------
# Reload PowerShell session to ensure environment updates
Write-Host "`nReloading PowerShell session to apply updated PATHs and modules..." -ForegroundColor Cyan
. $PROFILE

$CONFIG = "windows.conf.yaml"
$DOTBOT_DIR = "dotbot"

$DOTBOT_BIN = "bin/dotbot"
$BASEDIR = $PSScriptRoot

Set-Location $BASEDIR
git -C $DOTBOT_DIR submodule sync --quiet --recursive
git submodule update --init --recursive $DOTBOT_DIR

foreach ($PYTHON in ('python', 'python3', 'python2')) {
    # Python redirects to Microsoft Store in Windows 10 when not installed
    if (& { $ErrorActionPreference = "SilentlyContinue"
            ![string]::IsNullOrEmpty((&$PYTHON -V))
            $ErrorActionPreference = "Stop" }) {
        &$PYTHON $(Join-Path $BASEDIR -ChildPath $DOTBOT_DIR | Join-Path -ChildPath $DOTBOT_BIN) -d $BASEDIR -c $CONFIG $Args
        return
    }
}

Write-Host "`nSetup complete! You need to restart your PC for changes to take effect."