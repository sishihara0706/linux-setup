#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

with_tools=false
tools_only=false
for arg in "$@"; do
    case "$arg" in
        --with-tools) with_tools=true ;;
        --tools-only) tools_only=true ;;
        -h|--help)
            echo "Usage: ./setup.sh [--with-tools | --tools-only]"
            echo "  (引数なし)    OSパッケージと共通dotfilesを設定"
            echo "  --with-tools  通常セットアップに ~/tools の設定を追加"
            echo "  --tools-only  ~/tools とBashの読み込み設定のみ実行（sudo不要）"
            exit 0
            ;;
        *) echo "不明な引数: $arg" >&2; exit 1 ;;
    esac
done
if $with_tools && $tools_only; then
    echo "--with-tools と --tools-only は同時に指定できません" >&2
    exit 1
fi

if $tools_only; then
    source "$SCRIPT_DIR/distro/tools.sh"
    setup_tools
    exit 0
fi

if [[ ! -f /etc/os-release ]]; then
    echo "/etc/os-release が見つかりません"
    exit 1
fi

source /etc/os-release

echo "Detected OS: ${PRETTY_NAME:-unknown}"

case "${ID:-}" in
    elementary)
        source "$SCRIPT_DIR/distro/elementary.sh"
        ;;
    ubuntu)
        source "$SCRIPT_DIR/distro/ubuntu.sh"
        ;;
    raspbian)
        source "$SCRIPT_DIR/distro/raspberrypi.sh"
        ;;
    debian)
        if [[ -r /proc/device-tree/model ]] &&
            grep -q '^Raspberry Pi' /proc/device-tree/model; then
            source "$SCRIPT_DIR/distro/raspberrypi.sh"
        else
            source "$SCRIPT_DIR/distro/debian.sh"
        fi
        ;;
    rocky)
        source "$SCRIPT_DIR/distro/rocky.sh"
        ;;
    arch)
        source "$SCRIPT_DIR/distro/arch.sh"
        ;;
    *)
        echo "未対応OS: ${ID:-unknown}"
        exit 1
        ;;
esac

source "$SCRIPT_DIR/distro/common.sh"

install_packages
setup_common
if $with_tools; then
    source "$SCRIPT_DIR/distro/tools.sh"
    setup_tools
fi
