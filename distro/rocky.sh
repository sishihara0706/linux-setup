#!/usr/bin/env bash

install_packages()
{
    echo "==> Updating Rocky Linux"

    sudo dnf upgrade -y

    echo "==> Installing basic packages"

    sudo dnf install -y \
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
        gcc \
        gcc-c++ \
        clang \
        cmake \
        ninja-build \
        gdb \
        valgrind \
        strace \
        ltrace \
        ripgrep \
        openssh-server

    echo "==> Installing development tools"

    sudo dnf group install -y "Development Tools"

    echo "==> Installing fd"

    if dnf list --available fd-find >/dev/null 2>&1; then
        sudo dnf install -y fd-find
    elif dnf list --available fd >/dev/null 2>&1; then
        sudo dnf install -y fd
    else
        echo "WARN: fd package not found"
    fi

    echo "==> Enabling SSH"

    sudo systemctl enable --now sshd
}