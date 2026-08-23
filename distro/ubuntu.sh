#!/usr/bin/env bash

install_packages()
{
    echo "==> Updating Ubuntu"

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
        gcc \
        g++ \
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

    echo "==> Enabling SSH"

    sudo systemctl enable --now ssh
}