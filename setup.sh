#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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