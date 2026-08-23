#!/usr/bin/env bash

setup_common()
{
    local repo_dir
    repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    echo "==> Setting up common configuration"

    setup_file \
        "$repo_dir/dotfiles/bash_aliases" \
        "$HOME/.bash_aliases"

    setup_file \
        "$repo_dir/dotfiles/vimrc" \
        "$HOME/.vimrc"

    setup_file \
        "$repo_dir/dotfiles/gitconfig" \
        "$HOME/.gitconfig"

    setup_bashrc

    echo
    echo "========================================"
    echo " Setup completed"
    echo "========================================"
    echo
    echo "Reload shell:"
    echo "  source ~/.bashrc"
}

setup_file()
{
    local src="$1"
    local dst="$2"

    if [[ -e "$dst" && ! -L "$dst" ]]; then
        local backup="${dst}.backup"

        if [[ -e "$backup" ]]; then
            backup="${dst}.backup.$(date +%Y%m%d-%H%M%S)"
        fi

        echo "Backing up:"
        echo "  $dst -> $backup"

        mv "$dst" "$backup"
    fi

    ln -sfn "$src" "$dst"

    echo "Linked:"
    echo "  $dst -> $src"
}

setup_bashrc()
{
    local line='[ -f ~/.bash_aliases ] && source ~/.bash_aliases'

    touch "$HOME/.bashrc"

    if ! grep -Fxq "$line" "$HOME/.bashrc"; then
        echo >> "$HOME/.bashrc"
        echo "$line" >> "$HOME/.bashrc"
    fi
}