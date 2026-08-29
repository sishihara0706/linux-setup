#!/usr/bin/env bash

install_packages()
{
    echo "==> Updating Arch Linux"

    sudo pacman -Syu --noconfirm

    echo "==> Installing packages"

    sudo pacman -S --needed --noconfirm \
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
        base-devel \
        clang \
        cmake \
        ninja \
        gdb \
        valgrind \
        strace \
        ltrace \
        ripgrep \
        fd \
        github-cli \
        openssh

    echo "==> Enabling SSH"

    sudo systemctl enable --now sshd
}
