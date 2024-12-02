# Variables
$baseurl = "https://1337x.to"
$cachedir = "$HOME\AppData\Local\flix-cli\temp"
New-Item -ItemType Directory -Force -Path $cachedir > $null

# Function to print styled text
function Print-Style {
    param (
        [string]$Message,
        [string]$Type = "default"
    )
    $colors = @{
        "info"    = "Cyan"
        "success" = "Green"
        "warning" = "Yellow"
        "danger"  = "Red"
        "default" = "White"
    }
    $color = $colors[$Type]
    Write-Host $Message -ForegroundColor $color
}

# Function to check dependencies
function Check-Dependencies {
    param ([string[]]$Commands)
    foreach ($cmd in $Commands) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            Print-Style "$cmd is not installed. Please install it." "danger"
            exit 1
        }
    }
}

# Function to perform a search
function Perform-Search {
    param ([string]$Query)
    $encodedQuery = $Query -replace ' ', '+'
    Invoke-WebRequest -Uri "$baseurl/search/$encodedQuery/1/" -OutFile "$cachedir\tmp.html"
}

# Function to extract titles
function Extract-Titles {
    Select-String -Path "$cachedir\tmp.html" -Pattern '<a href="/torrent/.*</a>' | ForEach-Object {
        $_.Matches.Value -replace '<[^>]*>', ''
    }
}

# Function to extract URLs
function Extract-URLs {
    Select-String -Path "$cachedir\tmp.html" -Pattern '<a href="/torrent/[^"]+"' | ForEach-Object {
        ($_.Matches.Value -replace '<a href="', '') -replace '"', ''
    }
}

# Function to select a torrent using fzf
function Select-Torrent {
    param ([string[]]$Titles)
    $fzfInput = $Titles | ForEach-Object { "[{0}] {1}" -f ($Titles.IndexOf($_) + 1), $_ }
    $fzfInput | Set-Content -Path "$cachedir\fzf-input.txt"
    $selected = Get-Content "$cachedir\fzf-input.txt" | fzf
    if (-not $selected) {
        Print-Style "No results selected. Exiting..." "danger"
        exit 1
    }
    ($selected -split '\[')[1] -split '\]' | Select-Object -First 1
}

# Function to get the magnet link
function Get-Magnet-Link {
    param ([string]$FullURL)
    Invoke-WebRequest -Uri $FullURL -OutFile "$cachedir\tmp.html"
    Select-String -Path "$cachedir\tmp.html" -Pattern 'magnet:[^"]*' | ForEach-Object {
        $_.Matches[0].Value
    } | Select-Object -First 1
}

# Function to handle stream or download
function Handle-Action {
    param ([string]$Magnet)
    Print-Style "Stream or download? (s/d):" "info"
    $action = Read-Host
    if ($action -eq "d") {
        Print-Style "Select download directory:" "success"
        $downloadDir = (New-Object -ComObject Shell.Application).BrowseForFolder(0, "Select a folder", 0).Self.Path
        if (-not $downloadDir) {
            Print-Style "No directory selected. Exiting..." "danger"
            exit 1
        }
        Print-Style "Downloading to $downloadDir..." "info"
        webtorrent download "$Magnet" --mpv -o "$downloadDir"
    } else {
        Print-Style "Streaming with mpv..." "info"
        webtorrent "$Magnet" --mpv
    }
}

# Cleanup function
function Cleanup {
    # Remove the flix-cli cache directory
    Remove-Item -Path "$cachedir" -Recurse -Force -ErrorAction SilentlyContinue

    # Remove the WebTorrent cache directory
    $webtorrentCache = "$env:TEMP\webtorrent"
    if (Test-Path -Path $webtorrentCache) {
        Remove-Item -Path $webtorrentCache -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Main script logic
try {
    Check-Dependencies -Commands @("curl", "mpv", "webtorrent", "fzf")

    # Get search query
    $query = if ($args.Count -eq 0) {
        Print-Style "Search:" "success"
        Read-Host
    } else {
        $args -join " "
    }

    Perform-Search -Query $query
    $titles = Extract-Titles

    if ($titles.Count -eq 0) {
        Print-Style "No results found. Please try again..." "danger"
        exit 1
    }

    $selectedIndex = Select-Torrent -Titles $titles
    $urls = Extract-URLs

    if ($urls.Count -eq 0) {
        Print-Style "Failed to retrieve any torrent links. Please check the website structure." "danger"
        exit 1
    }

    $fullURL = "$baseurl$($urls[$selectedIndex - 1])"

    $magnet = Get-Magnet-Link -FullURL $fullURL

    if (-not $magnet) {
        Print-Style "Failed to retrieve magnet link. Please check the URL or website structure." "danger"
        exit 1
    }

    Handle-Action -Magnet $magnet
} finally {
    Cleanup
}
