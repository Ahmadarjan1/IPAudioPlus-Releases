#!/bin/bash

# ------------------------------------------------------------------
# IPAudioPlus Setup & Auto-Installer Script
# ------------------------------------------------------------------
# Project: IPAudioPlus
# Plugin:  enigma2-plugin-extensions-ipaudioplus
# Description: Installs or updates IPAudioPlus with exact architecture
#              and FFmpeg matching for your Enigma2 set-top box.
# ------------------------------------------------------------------

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

IPK=""
ARCH=""
CPU_ARCH=""
PY_VER=""
VERSION="2.4.1"
FFMPEG_VERSION=""
# GitHub Raw base URL — users who fork or clone can customize this URL:
BASE_URL="https://raw.githubusercontent.com/Ahmadarjan1/IPAudioPlus-Releases/main" # <-- set to your GitHub repo

SUPPORTED_FFMPEG_VERSIONS=(
    4
    6
    7
    8
)

SUPPORTED_PYTHON_VERSIONS=(
    3.9
    3.11
    3.12
    3.13
    3.14
)

welcome_message() {
    echo -e "${CYAN}##################################################${RESET}"
    echo -e "${YELLOW}###       Welcome to IPAudioPlus Setup!        ###${RESET}"
    echo -e "${YELLOW}###  Enigma2 Audio Streaming & Sync Plugin     ###${RESET}"
    echo -e "${CYAN}##################################################${RESET}"
}

detect_python_version() {
    if command -v python3 &>/dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
        PYTHON_VERSION=$(echo "$PYTHON_VERSION" | cut -d'.' -f1-2)
        echo "$PYTHON_VERSION"
    elif command -v python &>/dev/null; then
        PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
        PYTHON_VERSION=$(echo "$PYTHON_VERSION" | cut -d'.' -f1-2)
        echo "$PYTHON_VERSION"
    else
        echo "Python is not installed. Please install Python." >&2
        exit 1
    fi
}

detect_ffmpeg_version() {
    if opkg status ffmpeg &>/dev/null; then
        RAW_VER=$(opkg status ffmpeg | grep -i '^Version:' | awk '{print $2}' | cut -d'-' -f1)
        MAJOR_VERSION=$(echo "$RAW_VER" | cut -d'.' -f1)
        if (( MAJOR_VERSION > 4 )); then
            FFMPEG_VERSION=$(echo "$RAW_VER" | cut -d'.' -f1,2)
        fi

        if [[ "$MAJOR_VERSION" -eq 6 ]]; then
            FFMPEG_VERSION=6.1
        fi

        if [[ "$MAJOR_VERSION" -eq 7 ]]; then
            FFMPEG_VERSION=7.1
        fi

        if [[ "$MAJOR_VERSION" -eq 8 ]]; then
            FFMPEG_VERSION=8.0
        fi

        if [[ " ${SUPPORTED_FFMPEG_VERSIONS[@]} " =~ " $MAJOR_VERSION " ]]; then
            echo -e "${GREEN}FFmpeg major version $MAJOR_VERSION is supported (tag: ff${FFMPEG_VERSION}).${RESET}"
        else
            echo -e "${YELLOW}FFmpeg major version $MAJOR_VERSION is not supported.${RESET}"
            echo -e "${CYAN}Supported versions are: ${SUPPORTED_FFMPEG_VERSIONS[*]}${RESET}"
            exit 1
        fi
    else
        echo -e "${YELLOW}FFmpeg is not installed. Installing FFmpeg...${RESET}"
        opkg update && opkg install ffmpeg
        if opkg status ffmpeg &>/dev/null; then
            detect_ffmpeg_version
        else
            echo -e "${RED}Failed to install FFmpeg. Please check opkg feed.${RESET}"
            exit 1
        fi
    fi
}

detect_arm_arch() {
    OPKG_DIR="/etc/opkg/"
    if [[ -d "$OPKG_DIR" ]]; then
        if ls "$OPKG_DIR" | grep -q "cortexa15hf-neon-vfpv4"; then
            echo "cortexa15hf-neon-vfpv4"
            return
        elif ls "$OPKG_DIR" | grep -q "cortexa9hf-neon"; then
            echo "cortexa9hf-neon"
            return
        elif ls "$OPKG_DIR" | grep -q "cortexa7hf-vfp"; then
            echo "cortexa7hf-vfp"
            return
        elif ls "$OPKG_DIR" | grep -q "armv7ahf-vfp-neon"; then
            echo "armv7ahf-vfp-neon"
            return
        elif ls "$OPKG_DIR" | grep -q "armv7ahf-neon"; then
            echo "armv7ahf-neon"
            return
        fi
    fi

    # Fallback: check opkg print-architecture
    if command -v opkg &>/dev/null; then
        for a in cortexa15hf-neon-vfpv4 cortexa9hf-neon cortexa7hf-vfp armv7ahf-vfp-neon armv7ahf-neon; do
            if opkg print-architecture | grep -q "$a"; then
                echo "$a"
                return
            fi
        done
    fi

    echo "unknown"
}

detect_cpu_arch() {
    echo "Checking Python version..."
    PY_VER=$(detect_python_version)
    echo -e "Python version: ${GREEN}${PY_VER}${RESET}"

    if [[ " ${SUPPORTED_PYTHON_VERSIONS[@]} " =~ " $PY_VER " ]]; then
        echo -e "${GREEN}Python version $PY_VER is supported.${RESET}"
    else
        echo -e "${RED}Python version $PY_VER is not supported.${RESET}"
        echo -e "${CYAN}Supported versions are: ${SUPPORTED_PYTHON_VERSIONS[*]}${RESET}"
        exit 1
    fi

    echo "Checking FFmpeg version..."
    detect_ffmpeg_version

    echo "Detecting CPU architecture..."
    RAW_ARCH=$(uname -m)
    echo -e "CPU architecture reported: ${GREEN}${RAW_ARCH}${RESET}"

    if [[ "$RAW_ARCH" == *"arm"* ]]; then
        ARCH=$(detect_arm_arch)
        if [[ "$ARCH" != "unknown" ]]; then
            CPU_ARCH="arm"
            IPK="enigma2-plugin-extensions-ipaudioplus_${VERSION}_${ARCH}_py${PY_VER}_ff${FFMPEG_VERSION}.ipk"
            echo -e "Detected package architecture: ${GREEN}${ARCH}${RESET}"
        else
            echo -e "${RED}Unsupported ARM architecture tag: ${ARCH}${RESET}"
            exit 1
        fi
    elif [[ "$RAW_ARCH" == *"mips"* ]]; then
        ARCH="mips32el"
        CPU_ARCH="mipsel"
        IPK="enigma2-plugin-extensions-ipaudioplus_${VERSION}_${ARCH}_py${PY_VER}_ff${FFMPEG_VERSION}.ipk"
        echo -e "Detected package architecture: ${GREEN}${ARCH}${RESET}"
    elif [[ "$RAW_ARCH" == *"aarch64"* ]]; then
        ARCH="aarch64"
        CPU_ARCH="aarch64"
        IPK="enigma2-plugin-extensions-ipaudioplus_${VERSION}_${ARCH}_py${PY_VER}_ff${FFMPEG_VERSION}.ipk"
        echo -e "Detected package architecture: ${GREEN}${ARCH}${RESET}"
    else
        echo -e "${RED}Unsupported architecture: ${RAW_ARCH}${RESET}"
        exit 1
    fi
}

restart_box() {
    echo -e "${CYAN}Restarting Enigma2 GUI...${RESET}"
    killall -9 enigma2
    exit 0
}

install_plugin() {
    welcome_message
    detect_cpu_arch

    echo "Checking if IPAudioPlus is currently installed..."

    INSTALLED_VERSION=$(opkg status enigma2-plugin-extensions-ipaudioplus 2>/dev/null | grep -i '^Version:' | awk '{print $2}' | sed 's/+.*//')
    echo "Installer target version: $VERSION"

    if [[ -n "$INSTALLED_VERSION" ]]; then
        echo "Current installed version: $INSTALLED_VERSION"

        HIGHEST="$(echo -e "$INSTALLED_VERSION\n$VERSION" | sort -V | tail -n1)"

        if [[ "$HIGHEST" == "$INSTALLED_VERSION" && "$INSTALLED_VERSION" != "$VERSION" ]]; then
            echo -e "${GREEN}IPAudioPlus is already up to date (version $INSTALLED_VERSION). No action needed.${RESET}"
            exit 0
        fi

        echo -e "${YELLOW}Upgrading IPAudioPlus from $INSTALLED_VERSION to $VERSION...${RESET}"
        opkg remove --force-depends enigma2-plugin-extensions-ipaudioplus
    else
        echo -e "${GREEN}IPAudioPlus is not installed. Proceeding with fresh installation...${RESET}"
    fi

    IPK_URL="${BASE_URL}/v${VERSION}/python${PY_VER}/${CPU_ARCH}/${IPK}"
    echo -e "Downloading: ${CYAN}${IPK_URL}${RESET}"

    rm -f "/tmp/${IPK}"
    wget -q "--no-check-certificate" -O "/tmp/${IPK}" "$IPK_URL"
    if [[ ! -s "/tmp/${IPK}" ]]; then
        if command -v curl &>/dev/null; then
            curl -k -s -L "$IPK_URL" -o "/tmp/${IPK}"
        fi
    fi

    if [[ ! -s "/tmp/${IPK}" ]]; then
        echo -e "${RED}Download failed or downloaded file is empty:${RESET}"
        echo -e "${YELLOW}$IPK_URL${RESET}"
        echo -e "${CYAN}Please check your network connection or verify that BASE_URL points to a valid release repo.${RESET}"
        rm -f "/tmp/${IPK}"
        exit 1
    fi

    echo -e "${GREEN}Installing package ${IPK}...${RESET}"
    opkg install "/tmp/${IPK}"
    INSTALL_STATUS=$?
    rm -f "/tmp/${IPK}"

    if [[ $INSTALL_STATUS -eq 0 ]]; then
        echo -e "${GREEN}IPAudioPlus v${VERSION} installed successfully!${RESET}"
        restart_box
    else
        echo -e "${RED}Installation encountered an error (exit code: $INSTALL_STATUS).${RESET}"
        exit $INSTALL_STATUS
    fi
}

install_plugin
