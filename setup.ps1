# setup.ps1 - Installation and Uninstallation Script for flix-cli on Windows

# Main script parameters
param (
    [switch]$Uninstall
)

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

# Function to safely modify the Path environment variable
function Modify-Path {
    param (
        [string]$binDir,
        [switch]$Add
    )

    # Get the current user Path
    $pathEnv = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

    # Ensure Path is not null or empty
    if (-not $pathEnv) {
        $pathEnv = ""
    }

    # Split Path into entries
    $pathEntries = $pathEnv -split ';'

    if ($Add) {
        # Add binDir if it's not already in Path
        if (-not ($pathEntries -contains $binDir)) {
            Print-Style "Adding $binDir to PATH..." "info"
            $pathEntries += $binDir
            $newPathEnv = [string]::Join(';', $pathEntries)
            [System.Environment]::SetEnvironmentVariable("Path", $newPathEnv, [System.EnvironmentVariableTarget]::User)
            Print-Style "Please restart your terminal to apply the updated PATH." "warning"
        } else {
            Print-Style "$binDir is already in PATH." "success"
        }
    } else {
        # Remove binDir if it exists in Path
        if ($pathEntries -contains $binDir) {
            Print-Style "Removing $binDir from PATH..." "info"
            $pathEntries = $pathEntries | Where-Object { $_ -ne $binDir }
            $newPathEnv = [string]::Join(';', $pathEntries)
            [System.Environment]::SetEnvironmentVariable("Path", $newPathEnv, [System.EnvironmentVariableTarget]::User)
            Print-Style "Please restart your terminal to apply the updated PATH." "warning"
        } else {
            Print-Style "$binDir was not found in PATH." "warning"
        }
    }
}

# Function to install flix-cli
function Install-FlixCli {
    # Ensure Scoop is installed
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Print-Style "Scoop is not installed. Installing Scoop..." "info"
        Invoke-Expression "& ([scriptblock]::Create((irm get.scoop.sh)))"
    }

    # Install dependencies using Scoop
    $dependencies = @{
        "git"     = "git"
        "curl"    = "curl"
        "mpv"     = "mpv"
        "nodejs"  = "npm"
        "fzf"     = "fzf"
    }
    
    foreach ($dep in $dependencies.Keys) {
        $command = $dependencies[$dep]
        if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
            Print-Style "Installing $dep..." "info"
            scoop bucket add extras
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

    # Add binDir to PATH
    Modify-Path -binDir $binDir -Add
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

    # Remove binDir from PATH
    Modify-Path -binDir $binDir -Add:$false
    Print-Style "Uninstallation complete! flix-cli has been removed." "success"
}

# Main script execution
if ($Uninstall) {
    Uninstall-FlixCli
} else {
    Install-FlixCli
}
