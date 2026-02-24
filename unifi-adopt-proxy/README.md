# UniFi Adopt Proxy

Adopt UniFi devices to a cloud-hosted controller when you can't control DHCP options or local DNS.

## The problem

UniFi devices (Flex Mini, APs, etc.) discover their controller via mDNS (`unifi.local`) or DHCP Option 43. If your controller is in the cloud and you don't control DHCP or DNS on the local network, devices sit in an adoption loop forever.

## The solution

This container advertises `unifi.local` on your LAN via mDNS and proxies the `/inform` endpoint to your cloud controller. The device discovers it, adopts through the proxy, and the controller pushes its real inform URL to the device. Remove the proxy after adoption.

```
UniFi Device  ---mDNS unifi.local?--->  This Container  ---POST /inform--->  Cloud Controller
              <--adopt response------                   <--adopt response--
```

## Usage

### Docker Compose

1. Set your controller URL in `docker-compose.yml`
2. Run:

```bash
docker compose up -d
```

3. Adopt your device from the UniFi controller UI
4. Once adopted, tear down:

```bash
docker compose down
```

### Home Assistant add-on

Add the repository URL to **Settings > Add-ons > Add-on Store > Repositories**, install, and set the controller URL in the add-on config.

## Configuration

| Variable | Required | Example |
|----------|----------|---------|
| `UNIFI_CONTROLLER_URL` | Yes | `https://203.0.113.50:8443` |

## Requirements

- **Host networking** -- mDNS multicast must reach the LAN
- **Port 8080 free** -- UniFi's default inform port
- **Port 5353 available** -- mDNS

## License

MIT
