#!/bin/bash
# Set these values so the installer can still run in color
COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"
INFO="[i]"
# shellcheck disable=SC2034
DONE="${COL_LIGHT_GREEN} done!${COL_NC}"
OVER="\\r\\033[K"

checkApplications() {
    if [[ $(nvm --version) ]]; then
        echo -e "${TICK} NVM is installed"
    else
        echo -e "${CROSS} NVM is not installed"
        echo -e "${INFO} Installing NVM"
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash >/dev/null 2>&1
        echo -e "${DONE}"
    fi

    echo -e "${INFO} Installing Node"
    nvm install node >/dev/null 2>&1
    echo -e "${DONE}"

    echo -e "${INFO} Installing Visual Studio Code"
    sudo apt-get install wget gpg >/dev/null 2>&1
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings >/dev/null 2>&1
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt-get install apt-transport-https >/dev/null 2>&1
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install code >/dev/null 2>&1
    echo -e "${DONE}"

    echo -e "${INFO} Installing Discord"
    wget -qO- https://discordapp.com/api/download?platform=linux &
    format=deb | sudo apt-get install -y -qq >/dev/null 2>&1
    echo -e "${DONE}"

    echo -e "${INFO} Installing Spotify"
    curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add - >/dev/null 2>&1
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null 2>&1
    sudo apt-get update && sudo apt-get install spotify-client >/dev/null 2>&1
    echo -e "${DONE}"

    echo -e "${INFO} Modifying Spotify to add ad-blocker"
    if [[ $(which make) ]]; then
        echo -e "${TICK} make is installed"
    else
        echo -e "${CROSS} make is not installed"
        echo -e "${INFO} Installing make"
        sudo apt-get install build-essential >/dev/null 2>&1
        echo -e "${DONE}"
    fi
    echo -e "${INFO} Checking curl installation...${OVER}"
    which curl &>/dev/null || sudo apt install curl -y >/dev/null 2>&1
    echo -e "${TICK} Curl is installed!"
    echo -e "${INFO} Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh >/dev/null 2>&1
    echo -e "${DONE}"
    echo -e "${INFO} Cloning Adblock repository"
    git clone https://github.com/abba23/spotify-adblock.git >/dev/null 2>&1
    cd spotify-adblock >/dev/null 2>&1
    make >/dev/null 2>&1
    sudo make install >/dev/null 2>&1
    cd ~/.local/share/applications
    echo "  [Desktop Entry]
  Type=Application
  Name=Spotify (adblock)
  GenericName=Music Player
  Icon=spotify-client
  TryExec=spotify
  Exec=env LD_PRELOAD=/usr/local/lib/spotify-adblock.so spotify %U
  Terminal=false
  MimeType=x-scheme-handler/spotify;
  Categories=Audio;Music;Player;AudioVideo;
  StartupWMClass=spotify
" >>spotify-adblock.desktop
    cd ~
    echo -e "${DONE}"
    echo -e "${INFO} Installing Veracrypt v1.25.9...${OVER}"
    wget https://launchpad.net/veracrypt/trunk/1.25.9/+download/veracrypt-1.25.9-Ubuntu-22.04-amd64.deb >/dev/null 2>&1
    sudo dpkg -i veracrypt-1.25.9-Ubuntu-22.04-amd64.deb >/dev/null 2>&1
    echo -e "${DONE}"

}

main() {

    local str="User root check"
    printf "\\n"

    # If the user's id is zero,
    if [[ "${EUID}" -eq 0 ]]; then
        # they are root and all is good
        printf "  %b %s\\n" "${TICK}" "${str}"
    else
        # Otherwise, they do not have enough privileges, so let the user know
        printf "  %b %s\\n" "${INFO}" "${str}"
        printf "  %b %bScript called with non-root privileges%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
        printf "      Re-run this script with sudo\\n"

        exit 0
    fi

    # Update the system
    printf "  %b %bUpdating system...%b\\n" "${INFO}" "${COL_LIGHT_GREEN}" "${COL_NC}"
    sudo apt-get update -y >/dev/null 2>&1
    sudo apt-get upgrade -y >/dev/null 2>&1
    printf "  %b %bSystem updated%b\\n" "${TICK}" "${COL_LIGHT_GREEN}" "${COL_NC}"
}

main "$@"
