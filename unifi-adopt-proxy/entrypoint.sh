#!/bin/sh
set -e

# --- resolve controller URL ---
# HA add-on mode: read from /data/options.json
# Standalone mode: read from environment variable
if [ -f /data/options.json ]; then
    UNIFI_CONTROLLER_URL=$(jq -r '.controller_url' /data/options.json)
    echo "HA add-on mode: controller_url from options.json"
fi

if [ -z "$UNIFI_CONTROLLER_URL" ]; then
    echo "ERROR: UNIFI_CONTROLLER_URL is not set."
    echo "  Standalone: set it in docker-compose.yml or pass -e UNIFI_CONTROLLER_URL=..."
    echo "  HA add-on:  configure controller_url in the add-on settings"
    exit 1
fi

# --- validate URL ---
case "$UNIFI_CONTROLLER_URL" in
    https://*|http://*)
        if printf '%s' "$UNIFI_CONTROLLER_URL" | grep -qE '[[:space:];{}]'; then
            echo "ERROR: UNIFI_CONTROLLER_URL contains invalid characters"
            exit 1
        fi
        ;;
    *)
        echo "ERROR: UNIFI_CONTROLLER_URL must start with http:// or https://"
        exit 1
        ;;
esac

echo "Proxying :8080/inform -> ${UNIFI_CONTROLLER_URL}"

# --- generate nginx config ---
export UNIFI_CONTROLLER_URL
envsubst '${UNIFI_CONTROLLER_URL}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

# --- configure avahi hostname ---
# set hostname to "unifi" so mDNS resolves unifi.local
AVAHI_CONF="/etc/avahi/avahi-daemon.conf"
if [ -f "$AVAHI_CONF" ]; then
    sed -i 's/^#*host-name=.*/host-name=unifi/' "$AVAHI_CONF"
else
    mkdir -p /etc/avahi
    cat > "$AVAHI_CONF" <<EOF
[server]
host-name=unifi
use-ipv4=yes
use-ipv6=no
allow-interfaces=eth0,end0,wlan0

[publish]
publish-addresses=yes
publish-hinfo=no
publish-workstation=no

[reflector]

[rlimits]
EOF
fi

# --- start dbus (required by avahi) ---
mkdir -p /run/dbus
rm -f /run/dbus/pid
dbus-daemon --system --fork

# --- start avahi ---
avahi-daemon --daemonize || {
    echo "ERROR: avahi-daemon failed to start"
    exit 1
}
echo "avahi-daemon started (advertising unifi.local)"

# --- start nginx (foreground, PID 1 for signal handling) ---
exec nginx -g 'daemon off;'
