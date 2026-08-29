#!/usr/bin/env bash

DISTRO_NAME="Raspberry Pi OS"
DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DISTRO_DIR/ubuntu.sh"

package_groups()
{
    printf '%s\n' common development network python raspberrypi
}

map_package()
{
    case "$1" in
        gpiozero) MAPPED_PACKAGES=(python3-gpiozero) ;;
        lgpio) MAPPED_PACKAGES=(python3-lgpio) ;;
        mqtt-client) MAPPED_PACKAGES=(mosquitto-clients) ;;
        *) map_debian_package "$1" ;;
    esac
}
