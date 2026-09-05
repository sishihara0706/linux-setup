#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
test_home="$test_dir/home with spaces"
mkdir -p "$test_home"

run_setup() {
    env HOME="$test_home" bash "$repo_dir/setup.sh" "$@"
}

run_setup --help >/dev/null
if run_setup --invalid >/dev/null 2>&1; then exit 1; fi
if run_setup --tools-only --with-tools >/dev/null 2>&1; then exit 1; fi
[[ ! -e "$test_home/tools" ]]

run_setup --tools-only >/dev/null
[[ -x "$test_home/tools/bash-shortcuts" ]]
[[ ! -e "$test_home/.gitconfig" && ! -e "$test_home/.vimrc" ]]
cp "$test_home/.bash_aliases" "$test_dir/aliases.first"
cp "$test_home/.bashrc" "$test_dir/bashrc.first"
printf '# user tool\n' > "$test_home/tools/crun"
run_setup --tools-only >/dev/null
cmp "$test_home/.bash_aliases" "$test_dir/aliases.first"
cmp "$test_home/.bashrc" "$test_dir/bashrc.first"
[[ "$(cat "$test_home/tools/crun")" == '# user tool' ]]
env HOME="$test_home" PATH=/usr/bin:/bin bash --noprofile --norc -ec '
    source "$HOME/.bashrc"
    first_path="$PATH"
    source "$HOME/.bashrc"
    [[ "$PATH" == "$first_path" ]]
    [[ "$(command -v bash-shortcuts)" == "$HOME/tools/bash-shortcuts" ]]
    shopt -s expand_aliases
    eval "bs" | grep -q "Bash Shortcut Cheat Sheet"
    eval '\''mcd "$HOME/new directory"'\''
    [[ "$PWD" == "$HOME/new directory" ]]
    alias ga="git add"
    source "$HOME/.bash_aliases.tools"
    [[ "$(alias ga)" == "alias ga="*"git add"* ]]
    "$HOME/tools/command-register" quoted "printf '\''%s\\n'\'' '\''hello world'\''"
    source "$HOME/.bash_aliases"
    [[ "$(eval quoted)" == "hello world" ]]
'

# Old installations use tracked dotfiles via symlinks.
old_home="$test_dir/old-home"
mkdir -p "$old_home"
printf 'alias personal="echo preserved"\n' > "$test_dir/old-aliases"
printf '# original bashrc\n' > "$test_dir/old-bashrc"
cp "$test_dir/old-aliases" "$test_dir/aliases.expected"
ln -s "$test_dir/old-aliases" "$old_home/.bash_aliases"
ln -s "$test_dir/old-bashrc" "$old_home/.bashrc"
env HOME="$old_home" bash "$repo_dir/setup.sh" --tools-only >/dev/null
cmp "$test_dir/old-aliases" "$test_dir/aliases.expected"
[[ "$(cat "$test_dir/old-bashrc")" == '# original bashrc' ]]
[[ ! -L "$old_home/.bash_aliases" && ! -L "$old_home/.bashrc" ]]
grep -q personal "$old_home/.bash_aliases"
backups=("$old_home"/.bash_aliases.backup.*/original)
[[ -L "${backups[0]}" ]]
# Exercise full setup with package installation replaced by a stub.
fixture="$test_dir/repo"
full_home="$test_dir/full-home"
mkdir -p "$fixture/distro" "$full_home"
cp "$repo_dir/setup.sh" "$fixture/"
cp -R "$repo_dir/dotfiles" "$repo_dir/tools" "$fixture/"
cp "$repo_dir/distro/common.sh" "$repo_dir/distro/tools.sh" "$fixture/distro/"
for distro in elementary ubuntu raspberrypi debian rocky arch; do
    printf 'install_packages() { touch "$HOME/packages-called"; }\n' > "$fixture/distro/$distro.sh"
done
env HOME="$full_home" bash "$fixture/setup.sh" </dev/null >/dev/null
[[ -f "$full_home/packages-called" && ! -e "$full_home/tools" ]]
env HOME="$full_home" bash "$fixture/setup.sh" --with-tools </dev/null >/dev/null
[[ -x "$full_home/tools/bash-shortcuts" && -L "$full_home/.vimrc" ]]
env HOME="$full_home" PATH=/usr/bin:/bin bash -ec 'source "$HOME/.bash_aliases"; alias bs >/dev/null'
echo 'PASS: default/with-tools (packages stubbed), tools-only, repeat installation, custom files, aliases, symlinks, spaced paths'
