# flix-cli (Windows Version)

flix-cli is a command-line tool for searching and streaming movies using magnet links and [webtorrent-cli](https://github.com/webtorrent/webtorrent-cli).

## How It Works

flix-cli is a PowerShell script that scrapes movies from 1337x to retrieve magnet links, enabling you to stream movies directly in your terminal using `mpv` and `webtorrent-cli`. The script relies on utilities available in Windows, including PowerShell and `fzf` for interactive selection.

## Warning

- **Use a VPN:** This script retrieves torrents from 1337x, which is a torrent site that ISPs usually don't like. Always use a VPN.
- **NSFW Content:** The script doesn't filter out NSFW content. Be cautious.
- **No Series Support:** Currently, the script does not support TV series and will play a random episode if a series is searched. A workaround is to search for specific episodes.

## Requirements

- [Node.js](https://nodejs.org/) and npm
- [webtorrent-cli](https://github.com/webtorrent/webtorrent-cli)
- [mpv Media Player](https://mpv.io/)
- [fzf](https://github.com/junegunn/fzf)

## Installation

### Using the Setup Script

1. Install scoop if you don't have it, from [here](https://scoop.sh/). If you do, then skip this.

2. Install git with scoop

    ```
    scoop install git
    ```

2. Clone the repository:

    ```
    git clone https://github.com/d4r1us-drk/flix-cli_win.git
    cd flix-cli_win
    ```

3. Run the setup script to install dependencies and configure the script:

    ```
    .\setup.ps1
    ```

The setup script will:

- Install required dependencies using Scoop if they are not already installed.
- Install `webtorrent-cli` globally using npm.
- Install the `flix-cli` script to a user directory (`$HOME\AppData\Local\flix-cli\bin`).
- Add the installation directory to your PATH.

Restart your terminal to apply the updated PATH.

## Usage

To search for a movie, use the following command:

```powershell
flix-cli.ps1 <search>
```

Alternatively, you can enter the program to get a search prompt by simply running:

```powershell
flix-cli.ps1
```

The search results will be displayed in the following format:

- **First column:** Total size of the file.
- **Second column:** Name of the torrent (including details like quality, video codec, audio codec, etc.).
- **Third column:** Seeders and leechers.

After selecting a torrent, you can choose whether to stream it using `mpv` or download it to a specified directory.

## Uninstallation

To uninstall flix-cli, run the setup script with the `-Uninstall` flag:

```powershell
.\setup.ps1 -Uninstall
```

The uninstallation process will:

- Remove the `flix-cli` installation directory.
- Remove the installation directory from your PATH.

Restart your terminal to apply the updated PATH.

## Alternatives

Here are some alternatives for streaming other types of content:

- **Anime:** [ani-cli by pystardust](https://github.com/pystardust/ani-cli)
- **YouTube:** [ytfzf by pystardust](https://github.com/pystardust/ytfzf)

## License

This project is licensed under the [GPL-3.0 License](https://raw.githubusercontent.com/Illumina/licenses/master/gpl-3.0.txt).

