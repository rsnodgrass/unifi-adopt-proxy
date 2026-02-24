ARG BUILD_FROM=alpine:3.21
FROM ${BUILD_FROM}

RUN apk add --no-cache \
    nginx \
    avahi \
    avahi-tools \
    dbus \
    jq \
    && rm -rf /var/cache/apk/*
# envsubst (from gettext) is provided by the HA base image

# avahi service definition
COPY avahi/unifi.service /etc/avahi/services/unifi.service

# nginx template (envsubst'd at runtime)
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# entrypoint handles both HA add-on and standalone modes
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/health || exit 1

LABEL \
    io.hass.name="UniFi Adopt Proxy" \
    io.hass.description="mDNS + reverse proxy for adopting UniFi devices to a cloud controller" \
    io.hass.version="1.0.3" \
    io.hass.type="addon" \
    io.hass.arch="aarch64|amd64|armhf|armv7|i386"

CMD ["/entrypoint.sh"]
