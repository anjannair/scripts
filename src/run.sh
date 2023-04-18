#!/bin/sh
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

dockerInstall() {
    if [[ $(which docker) ]]; then
        echo -e "${TICK} Docker is installed"
        if [[ $(which docker-compose) ]]; then
            echo -e "${TICK} Docker-Compose is installed"
        else
            echo -e "${INFO} Checking curl installation...${OVER}"
            which curl &
            >/dev/null || sudo apt install curl -y
            echo -e "${TICK} Curl is installed!"
            echo -e "${INFO} Docker-Compose is not installed. Installing..."
            sudo curl -L "https://github.com/docker/compose/releases/download/$(curl https://github.com/docker/compose/releases | grep -m1 '<a href="/docker/compose/releases/download/' | grep -o 'v[0-9:].[0-9].[0-9]')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            echo -e "${TICK} Docker-compose installed."
        fi
    else
        echo -e "${INFO} Checking curl installation...${OVER}"
        which curl &
        >/dev/null || sudo apt install curl -y
        echo -e "${TICK} Curl is installed!"
        echo -e "${INFO} Docker is not installed. Please install and run this script again! - https://docs.docker.com/engine/install/ubuntu/"
    fi
}

dockerCheck() {

    printf "%b %bYou will now be entering a login password. This will now be your login password!%b: " "${INFO}" "${COL_LIGHT_GREEN}" "${COL_NC}"

    read -s PASSWORD
    stty echo

    docker build -t pigen .

    docker run -d --restart unless-stopped \
        --env "PORT=4001" \
        --env "PS_SHARED_SECRET=${PASSWORD}" \
        --publish 4001:4001/tcp \
        --volume "${PWD}/data:/data" \
        pigen
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
        printf "      This PiGen script requires elevated privileges to install and run\\n"
        printf "      Re-run this script with sudo\\n"
        printf "      Make sure to download this script from a trusted source\\n\\n"

        exit 0
    fi

    # Update the system
    # Path to the apt update log file
    APT_LOG=/var/log/apt/history.log

    # Get the last modification time of the apt update log file
    LAST_UPDATE=$(stat -c %Y "$APT_LOG")

    # Get the current time
    NOW=$(date +%s)

    # Calculate the time difference between the last update and now
    DIFF=$((NOW - LAST_UPDATE))

    # If the time difference is less than 24 hours (86400 seconds), apt update was run recently
    if [ $DIFF -lt 86400 ]; then
        printf "  %b %bapt update was run within the last 24 hours. Hence skipping apt update %b" "${INFO}" "${COL_LIGHT_GREEN}" "${COL_NC}"
    else
        printf "  %b %bUpdating system...%b\\n" "${INFO}" "${COL_LIGHT_GREEN}" "${COL_NC}"
        sudo apt-get update -y
        sudo apt-get upgrade -y
        printf "  %b %bSystem updated%b\\n" "${TICK}" "${COL_LIGHT_GREEN}" "${COL_NC}"
    fi

    # Checking the docker installation
    dockerInstall
    # Installing Git
    echo -e "${INFO} Checking Git installation...${OVER}"
    which git &
    >/dev/null || sudo apt install git -y
    echo -e "${TICK} Git is installed!"
    #!/bin/bash

    # Get the current working directory
    CURRENT_DIR=$(pwd)

    # Extract the name of the current folder
    CURRENT_FOLDER=$(basename "$CURRENT_DIR")

    # Print the name of the current folder
    echo "Current folder: $CURRENT_FOLDER"

    if [ "$CURRENT_FOLDER" = "PiGen" ]; then
        git fetch
        git pull
        git checkout letsgo
    else
        echo -e "${INFO} Cloning PiGen...${OVER}"
        git clone https://github.com/anjannair/PiGen.git
        echo -e "${TICK} PiGen cloned!"
        cd PiGen
        git checkout letsgo
    fi
    dockerCheck
}

main "$@"
