# ============================================
# Winget Installation Script for Core Packages
# ============================================

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
    @{ Id = "ajeetdsouza.zoxide"; Name = "zoxide" }
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

# -------------------------------
# Remove existing Python installations and install latest stable Python
# -------------------------------
Write-Host "`nChecking for existing Python installations..." -ForegroundColor Cyan

# Get all Python packages known to winget
$pythonPackages = winget list --id Python.Python* -s winget | Select-String "Python"

if ($pythonPackages) {
    Write-Host "Found existing Python installations. Uninstalling..." -ForegroundColor Yellow
    foreach ($pkg in $pythonPackages) {
        # Extract the package ID from winget output
        $pkgId = ($pkg -split '\s+')[0]
        try {
            Write-Host "Uninstalling $pkgId..." -ForegroundColor Yellow
            winget uninstall --id $pkgId --silent --accept-source-agreements --accept-package-agreements -h
        } catch {
            # Use ${} to safely delimit variables inside the string
            Write-Warning "Failed to uninstall ${pkgId}: ${_}"
        }
    }
} else {
    Write-Host "No existing Python installations found." -ForegroundColor Green
}

# Install latest stable Python
Write-Host "`nInstalling latest stable Python via winget..." -ForegroundColor Cyan
try {
    winget install --id Python.Python.3 --silent --accept-source-agreements --accept-package-agreements -h --force
    Write-Host "Python installed successfully." -ForegroundColor Green
} catch {
    Write-Warning "Failed to install Python: ${_}"
}


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

# Get the current script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Source paths in your repo folder
$sourceProfile = Join-Path $scriptDir "powershell_settings.ps1"
$sourceThemeDir = Join-Path $scriptDir "Themes"
$sourceWTConfig = Join-Path $scriptDir "windows_terminal_settings.json"

# Destination paths
$destProfile = $PROFILE
$destThemeDir = "$env:USERPROFILE\Documents\PowerShell\Themes"
$destWTConfig = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Ensure theme directory exists
if (-not (Test-Path $destThemeDir)) {
    New-Item -ItemType Directory -Path $destThemeDir -Force | Out-Null
}

# Symlink PowerShell profile
if (Test-Path $destProfile) {
    Write-Host "Existing profile detected, backing it up..."
    Rename-Item -Path $destProfile -NewName ($destProfile + ".backup") -Force
}
New-Item -ItemType SymbolicLink -Path $destProfile -Target $sourceProfile -Force
Write-Host "Symlink created for PowerShell profile."

# Symlink Themes folder
if (Test-Path $destThemeDir) {
    Write-Host "Existing Themes folder detected, backing it up..."
    Rename-Item -Path $destThemeDir -NewName ($destThemeDir + ".backup") -Force
}
New-Item -ItemType SymbolicLink -Path $destThemeDir -Target $sourceThemeDir -Force
Write-Host "Symlink created for Themes folder."

# Symlink Windows Terminal settings
if (Test-Path $destWTConfig) {
    Write-Host "Existing Windows Terminal config detected, backing it up..."
    Rename-Item -Path $destWTConfig -NewName ($destWTConfig + ".backup") -Force
}
New-Item -ItemType SymbolicLink -Path $destWTConfig -Target $sourceWTConfig -Force
Write-Host "Symlink created for Windows Terminal settings.json."

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

Write-Host "`nSetup complete! You need to restart your PC for changes to take effect."