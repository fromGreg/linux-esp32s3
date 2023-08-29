#!/usr/bin/env bash


# If -w flag is enabled and followed by the desired SSID and PSK for the WPA to connect -> sets it up in buildroot
configure_wpa() {
    local ssid="$1"
    local psk="$2"

    if [ -z "$ssid" ] || [ -z "$psk" ]; then
        echo "Need to specify SSID and PSK if -w flag enabled"
        echo "Usage: . $BASH_SOURCE [- w SSID PSK]"
        # Need to return when script is sourced, exit 1 causes the sourcing terminal process to exit
        return 1
    fi

    local conf="$(pwd)/buildroot/board/espressif/esp32s3/rootfs_overlay/etc/wpa_supplicant.conf"
    if [[ ! -f "$conf" ]]; then
        echo "File wpa_supplicant.conf does not exist in $conf"
        # Need to return when script is sourced, exit 1 causes the sourcing terminal process to exit
        return 1
    fi

    printf "network={\n    ssid="'"'"${ssid}"'"'"\n    psk="'"'"${psk}"'"'"\n}\n" | cat > $conf
    printf "wpa_supplicant.conf configured with...\n\tSSID: ${ssid}\n\tPSK: ${psk}\n"
}



if [ -n "${BASH_SOURCE-}" ] && [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Script needs to be sourced in order to work"
    echo "use 'source setup.sh' or '. setup.sh' instead of running the script directly"
    exit 1
elif [[ "$(pwd)" != */linux-esp32s3 ]]; then
    echo "Need to be in linux-esp32s3 directory to setup correctly"
    # Need to return when script is sourced, exit 1 causes the sourcing terminal process to exit
    return 1
else
    if [ -z "$1" ] || ([ "$1" = "-w" ] && configure_wpa $2 $3); then
        # Needed as root for this build environment, used e.g. by buildroot
        export ESP32S3_ROOT_DIR=$(pwd)
        # Needed by crosstool-NG
        export CT_PREFIX=$(pwd)/crosstool-NG/output
        # Needed to configure dynconf
        export CONF_DIR=$(pwd)/configs
        export ORIG=1
        printf "Exported environment variables...\n\tESP32S3_ROOT_DIR: $ESP32S3_ROOT_DIR\n\tCT_PREFIX: $CT_PREFIX\n\tCONF_DIR: $CONF_DIR\n\tORIG: $ORIG\n"
    else
        echo "Usage: . $BASH_SOURCE [ -w SSID PSK]"
    fi
fi

