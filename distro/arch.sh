#!/usr/bin/env bash

DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DISTRO_DIR/packages.sh"

install_packages()
{
    echo "==> Updating Arch Linux"

    sudo pacman -Syu --noconfirm

    echo "==> Installing packages"

    install_package_groups common development network python
    sudo pacman -S --needed --noconfirm "${RESOLVED_PACKAGES[@]}" github-cli openssh

    echo "==> Enabling SSH"

    sudo systemctl enable --now sshd
}

map_package()
{
    case "$1" in
        build-essential) MAPPED_PACKAGES=(base-devel) ;;
        pkg-config) MAPPED_PACKAGES=(pkgconf) ;;
        netcat) MAPPED_PACKAGES=(openbsd-netcat) ;;
        dnsutils) MAPPED_PACKAGES=(bind) ;;
        python3 | venv) MAPPED_PACKAGES=(python) ;;
        pip) MAPPED_PACKAGES=(python-pip) ;;
        pipx) MAPPED_PACKAGES=(python-pipx) ;;
        *) MAPPED_PACKAGES=("$1") ;;
    esac
}
