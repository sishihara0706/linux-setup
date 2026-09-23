#!/usr/bin/env bash

DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DISTRO_DIR/packages.sh"

install_packages()
{
    echo "==> Updating Fedora"

    sudo dnf upgrade -y

    echo "==> Installing packages"

    install_package_groups common development network python
    sudo dnf install -y "${RESOLVED_PACKAGES[@]}" openssh-server gh

    echo "==> Installing development tools"

    sudo dnf install -y '@development-tools'

    echo "==> Enabling SSH"

    sudo systemctl enable --now sshd
}

map_package()
{
    case "$1" in
        # build-essential は下の development-tools グループで導入する。
        build-essential) MAPPED_PACKAGES=() ;;
        fd) MAPPED_PACKAGES=(fd-find) ;;
        ninja) MAPPED_PACKAGES=(ninja-build) ;;
        pkg-config) MAPPED_PACKAGES=(pkgconf-pkg-config) ;;
        netcat) MAPPED_PACKAGES=(nmap-ncat) ;;
        dnsutils) MAPPED_PACKAGES=(bind-utils) ;;
        venv) MAPPED_PACKAGES=(python3) ;;
        pip) MAPPED_PACKAGES=(python3-pip) ;;
        *) MAPPED_PACKAGES=("$1") ;;
    esac
}
