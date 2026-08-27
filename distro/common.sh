#!/usr/bin/env bash

setup_common()
{
    local repo_dir current_git_name current_git_email
    repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    # 既存の設定がある場合は、共有 gitconfig に置き換える前に初期値として退避する。
    current_git_name="$(git config --global --get user.name 2>/dev/null || true)"
    current_git_email="$(git config --global --get user.email 2>/dev/null || true)"

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

    setup_git_identity "$current_git_name" "$current_git_email"

    setup_bashrc

    echo
    echo "========================================"
    echo " Setup completed"
    echo "========================================"
    echo
    echo "Reload shell:"
    echo "  source ~/.bashrc"
}

setup_git_identity()
{
    local current_name="$1"
    local current_email="$2"
    local git_name="${GIT_USER_NAME:-$current_name}"
    local git_email="${GIT_USER_EMAIL:-$current_email}"
    local input

    echo
    echo "==> Setting up Git identity"

    if [[ -t 0 ]]; then
        read -r -p "Git user name${git_name:+ [$git_name]}: " input
        git_name="${input:-$git_name}"

        read -r -p "Git email address${git_email:+ [$git_email]}: " input
        git_email="${input:-$git_email}"
    fi

    if [[ -z "$git_name" || -z "$git_email" ]]; then
        echo "WARN: Git identity was not set."
        echo "      Run setup.sh interactively, or set GIT_USER_NAME and GIT_USER_EMAIL."
        return
    fi

    touch "$HOME/.gitconfig.local"
    chmod 600 "$HOME/.gitconfig.local"
    git config --file "$HOME/.gitconfig.local" user.name "$git_name"
    git config --file "$HOME/.gitconfig.local" user.email "$git_email"

    echo "Git identity saved to ~/.gitconfig.local"
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
