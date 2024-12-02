# setup.ps1 - Installation and Uninstallation Script for flix-cli on Windows

# Define the user directory for installation
$installDir = "$HOME\AppData\Local\flix-cli"
$binDir = "$installDir\bin"

# Function to print styled messages
function Print-Style {
    param (
        [string]$Message,
        [string]$Type = "info"
    )

    $colors = @{
        "info"    = "Cyan"
        "success" = "Green"
        "warning" = "Yellow"
        "error"   = "Red"
    }

    $color = $colors[$Type]
    Write-Host $Message -ForegroundColor $color
}

# Function to install flix-cli
function Install-FlixCli {
    # Ensure Scoop is installed
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Print-Style "Scoop is not installed. Installing Scoop..." "info"
        Invoke-Expression "& ([scriptblock]::Create((irm get.scoop.sh)))"
    }

    # Install dependencies using Scoop
    $dependencies = @("git", "curl", "mpv", "nodejs", "fzf")
    foreach ($dep in $dependencies) {
        if (-not (scoop which $dep)) {
            Print-Style "Installing $dep..." "info"
            scoop install $dep
        } else {
            Print-Style "$dep is already installed." "success"
        }
    }

    # Install webtorrent-cli globally using npm
    if (-not (Get-Command webtorrent -ErrorAction SilentlyContinue)) {
        Print-Style "Installing webtorrent-cli..." "info"
        npm install -g webtorrent-cli
    } else {
        Print-Style "webtorrent-cli is already installed." "success"
    }

    # Create the installation directory
    if (-not (Test-Path -Path $installDir)) {
        Print-Style "Creating installation directory at $installDir..." "info"
        New-Item -ItemType Directory -Force -Path $installDir > $null
    }

    # Copy script files to the installation directory
    if (-not (Test-Path -Path $binDir)) {
        New-Item -ItemType Directory -Force -Path $binDir > $null
    }
    Print-Style "Installing flix-cli to $installDir..." "info"
    Copy-Item -Path (Join-Path $PSScriptRoot "flix-cli.ps1") -Destination $binDir -Force

    # Add the installation directory to PATH if not already present
    $pathEnv = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    if (-not $pathEnv.Contains($binDir)) {
        Print-Style "Adding $binDir to PATH..." "info"
        [System.Environment]::SetEnvironmentVariable("Path", "$pathEnv;$binDir", [System.EnvironmentVariableTarget]::User)
        Print-Style "Please restart your terminal to apply the updated PATH." "warning"
    } else {
        Print-Style "$binDir is already in PATH." "success"
    }

    Print-Style "Installation complete! You can now use flix-cli by running 'flix-cli.ps1' from any terminal." "success"
}

# Function to uninstall flix-cli
function Uninstall-FlixCli {
    # Remove the installation directory
    if (Test-Path -Path $installDir) {
        Print-Style "Removing installation directory at $installDir..." "info"
        Remove-Item -Recurse -Force -Path $installDir
    } else {
        Print-Style "Installation directory not found. Nothing to remove." "warning"
    }

    # Remove the installation directory from PATH
    $pathEnv = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    if ($pathEnv.Contains($binDir)) {
        Print-Style "Removing $binDir from PATH..." "info"
        $newPathEnv = ($pathEnv -split ';') | Where-Object { $_ -ne $binDir } -join ';'
        [System.Environment]::SetEnvironmentVariable("Path", $newPathEnv, [System.EnvironmentVariableTarget]::User)
        Print-Style "Please restart your terminal to apply the updated PATH." "warning"
    } else {
        Print-Style "$binDir was not found in PATH." "warning"
    }

    Print-Style "Uninstallation complete! flix-cli has been removed." "success"
}

# Main script
param (
    [switch]$Uninstall
)

if ($Uninstall) {
    Uninstall-FlixCli
} else {
    Install-FlixCli
}
