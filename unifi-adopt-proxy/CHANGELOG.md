## 1.0.3

- Fix entrypoint permission denied by switching from `ENTRYPOINT` to `CMD` (HA base images use S6-overlay as their entrypoint)
- Use `chmod a+x` for broader permission compatibility

## 1.0.2

- Fix `/inform` proxy returning 302 instead of forwarding to upstream controller
- Normalize controller URL by stripping trailing slash to prevent double-path issues

## 1.0.1

- Switch to Home Assistant base images for better compatibility
- Add `/health` endpoint for lightweight container healthchecks
- Improve nginx access logging with structured format and upstream timing
- Suppress healthcheck noise from logs
- Add AppArmor profile
- Add README

## 1.0.0

- Initial release
- mDNS advertisement of `unifi.local` via Avahi
- Reverse proxy `/inform` endpoint to cloud UniFi controller
- Support for both HA add-on and standalone Docker modes
