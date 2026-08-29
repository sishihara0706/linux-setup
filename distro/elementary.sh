#!/usr/bin/env bash

install_packages()
{
    echo "==> Updating elementary OS"

    sudo apt update
    sudo apt upgrade -y

    echo "==> Installing packages"

    sudo apt install -y \
        git \
        curl \
        wget \
        vim \
        tmux \
        htop \
        tree \
        jq \
        unzip \
        zip \
        build-essential \
        clang \
        cmake \
        ninja-build \
        gdb \
        valgrind \
        strace \
        ltrace \
        ripgrep \
        fd-find \
        openssh-server

    install_gh

    echo "==> Enabling SSH"

    sudo systemctl enable --now ssh
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
