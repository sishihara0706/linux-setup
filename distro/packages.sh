#!/usr/bin/env bash

# OS に依存しない論理パッケージ名。実際のパッケージ名は各 OS 側で解決する。
COMMON_PACKAGES=(
    git curl wget vim tmux htop tree jq unzip zip rsync ripgrep fd
)

DEVELOPMENT_PACKAGES=(
    build-essential clang cmake ninja pkg-config gdb valgrind strace ltrace shellcheck
)

NETWORK_PACKAGES=(
    netcat nmap tcpdump dnsutils traceroute iperf3 ethtool lsof
)

PYTHON_PACKAGES=(
    python3 pip venv pipx
)

RASPBERRYPI_PACKAGES=(
    raspi-config i2c-tools gpiozero lgpio gpiod mqtt-client
)

# requests、numpy、FastAPI などのアプリケーション依存はグローバルに入れず、
# プロジェクトごとの venv または uv で管理する。
# uv、ruff、mypy、pre-commit などの Python CLI は apt/dnf/pacman に固定せず、
# pipx install <tool> または uv tool install <tool> で導入する。

install_package_groups()
{
    local group logical_package
    local -a logical_packages
    local -A installed=()

    RESOLVED_PACKAGES=()

    for group in "$@"; do
        case "$group" in
            common) logical_packages=("${COMMON_PACKAGES[@]}") ;;
            development) logical_packages=("${DEVELOPMENT_PACKAGES[@]}") ;;
            network) logical_packages=("${NETWORK_PACKAGES[@]}") ;;
            python) logical_packages=("${PYTHON_PACKAGES[@]}") ;;
            raspberrypi) logical_packages=("${RASPBERRYPI_PACKAGES[@]}") ;;
            *)
                echo "Unknown package group: $group" >&2
                return 1
                ;;
        esac

        for logical_package in "${logical_packages[@]}"; do
            MAPPED_PACKAGES=()
            map_package "$logical_package"

            local package
            for package in "${MAPPED_PACKAGES[@]}"; do
                if [[ -n "$package" && -z "${installed[$package]:-}" ]]; then
                    RESOLVED_PACKAGES+=("$package")
                    installed["$package"]=1
                fi
            done
        done
    done
}
