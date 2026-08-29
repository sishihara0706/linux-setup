#!/usr/bin/env bash

DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DISTRO_DIR/packages.sh"

DISTRO_NAME="${DISTRO_NAME:-Ubuntu}"

install_packages()
{
    local -a groups

    echo "==> Updating $DISTRO_NAME"

    sudo apt update
    sudo apt upgrade -y

    echo "==> Installing packages"

    mapfile -t groups < <(package_groups)
    install_package_groups "${groups[@]}"
    sudo apt install -y "${RESOLVED_PACKAGES[@]}" openssh-server

    install_gh

    echo "==> Enabling SSH"

    sudo systemctl enable --now ssh
}

package_groups()
{
    printf '%s\n' common development network python
}

map_package()
{
    map_debian_package "$1"
}

map_debian_package()
{
    case "$1" in
        fd) MAPPED_PACKAGES=(fd-find) ;;
        ninja) MAPPED_PACKAGES=(ninja-build) ;;
        netcat) MAPPED_PACKAGES=(netcat-openbsd) ;;
        pip) MAPPED_PACKAGES=(python3-pip) ;;
        venv) MAPPED_PACKAGES=(python3-venv) ;;
        *) MAPPED_PACKAGES=("$1") ;;
    esac
}

install_gh()
{
    echo "==> Installing GitHub CLI"

    sudo mkdir -p -m 755 /etc/apt/keyrings
    local keyring
    keyring="$(mktemp)"
    wget -nv -O "$keyring" https://cli.github.com/packages/githubcli-archive-keyring.gpg
    sudo install -m 644 "$keyring" /etc/apt/keyrings/githubcli-archive-keyring.gpg
    rm -f "$keyring"

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

    sudo apt update
    sudo apt install -y gh
}
