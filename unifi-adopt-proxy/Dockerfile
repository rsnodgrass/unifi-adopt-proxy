ARG BUILD_FROM=alpine:3.21
FROM ${BUILD_FROM}

RUN apk add --no-cache \
    nginx \
    avahi \
    avahi-tools \
    dbus \
    gettext \
    jq \
    && rm -rf /var/cache/apk/*

# avahi service definition
COPY avahi/unifi.service /etc/avahi/services/unifi.service

# nginx template (envsubst'd at runtime)
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# main run script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/inform || exit 1

LABEL \
    io.hass.name="UniFi Adopt Proxy" \
    io.hass.description="mDNS + reverse proxy for adopting UniFi devices to a cloud controller" \
    io.hass.version="1.0.0" \
    io.hass.type="addon" \
    io.hass.arch="aarch64|amd64|armhf|armv7|i386"

ENTRYPOINT ["/entrypoint.sh"]
