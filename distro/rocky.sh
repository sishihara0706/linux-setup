#!/usr/bin/env bash

DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DISTRO_DIR/packages.sh"

install_packages()
{
    echo "==> Updating Rocky Linux"

    sudo dnf upgrade -y

    echo "==> Enabling EPEL repository"

    sudo dnf install -y epel-release

    echo "==> Installing packages"

    install_package_groups common development network python
    sudo dnf install -y "${RESOLVED_PACKAGES[@]}" openssh-server

    echo "==> Installing development tools"

    sudo dnf group install -y "Development Tools"

    echo "==> Installing GitHub CLI"

    sudo dnf install -y 'dnf-command(config-manager)'
    if [[ ! -f /etc/yum.repos.d/gh-cli.repo ]]; then
        sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    fi
    sudo dnf install -y gh

    echo "==> Enabling SSH"

    sudo systemctl enable --now sshd
}

map_package()
{
    case "$1" in
        # build-essential は下の Development Tools グループで導入する。
        build-essential) MAPPED_PACKAGES=() ;;
        fd)
            if dnf list --installed fd-find >/dev/null 2>&1 ||
                dnf list --available fd-find >/dev/null 2>&1; then
                MAPPED_PACKAGES=(fd-find)
            elif dnf list --installed fd >/dev/null 2>&1 ||
                dnf list --available fd >/dev/null 2>&1; then
                MAPPED_PACKAGES=(fd)
            else
                echo "WARN: fd package not found" >&2
                MAPPED_PACKAGES=()
            fi
            ;;
        ninja) MAPPED_PACKAGES=(ninja-build) ;;
        pkg-config) MAPPED_PACKAGES=(pkgconf-pkg-config) ;;
        netcat) MAPPED_PACKAGES=(nmap-ncat) ;;
        dnsutils) MAPPED_PACKAGES=(bind-utils) ;;
        venv) MAPPED_PACKAGES=(python3) ;;
        pip) MAPPED_PACKAGES=(python3-pip) ;;
        *) MAPPED_PACKAGES=("$1") ;;
    esac
}
