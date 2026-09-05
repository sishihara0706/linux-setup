#!/usr/bin/env bash

# Keep local tools and edits, including symlinks, on repeated installation.
install_optional_tool()
{
    local src="$1" dst="$2" mode="$3"
    if [[ -e "$dst" || -L "$dst" ]]; then
        echo "Kept existing: $dst"
    else
        install -m "$mode" -- "$src" "$dst"
        echo "Installed: $dst"
    fi
}

append_tools_source()
{
    local dst="$1" line="$2" backup_dir
    if [[ -f "$dst" ]] && grep -Fxq -- "$line" "$dst"; then
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ ! -f "$dst" ]]; then
            echo "設定先が通常ファイルではありません: $dst" >&2
            return 1
        fi
        backup_dir="$(mktemp -d "${dst}.backup.XXXXXXXX")"
        cp -a -- "$dst" "$backup_dir/original"
        # Detach symlinks so an older clone's tracked dotfile is not edited.
        if [[ -L "$dst" ]]; then
            cp -pL -- "$dst" "$backup_dir/edit"
            mv -T -- "$backup_dir/edit" "$dst"
        fi
        echo "Backup: $backup_dir/original"
    fi
    printf '\n%s\n' "$line" >> "$dst"
}

setup_tools()
{
    local repo_dir src mode dst
    repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    # Check configuration targets before installing anything.
    for dst in "$HOME/.bash_aliases" "$HOME/.bashrc" "$HOME/.bash_aliases.tools"; do
        if [[ ( -e "$dst" || -L "$dst" ) && ! -f "$dst" ]]; then
            echo "設定先が通常ファイルではありません: $dst" >&2
            return 1
        fi
    done
    mkdir -p -- "$HOME/tools"
    for src in "$repo_dir"/tools/*; do
        mode=755
        [[ "$src" != *.md ]] || mode=644
        install_optional_tool "$src" "$HOME/tools/${src##*/}" "$mode"
    done
    install_optional_tool "$repo_dir/dotfiles/bash_aliases.tools" "$HOME/.bash_aliases.tools" 644
    append_tools_source "$HOME/.bash_aliases" \
        '[ ! -f "$HOME/.bash_aliases.tools" ] || source "$HOME/.bash_aliases.tools"'
    append_tools_source "$HOME/.bashrc" \
        '[ -f ~/.bash_aliases ] && source ~/.bash_aliases'
    echo "Tools setup completed. Reload shell: source ~/.bashrc"
}
