# Mox Mail Server (Kamal)

Mox runs alongside the webapp on the same droplet. TLS for HTTP/HTTPS (autoconfig, MTA-STS) is handled by the Kamal proxy. Mox reuses the same Let's Encrypt certs for SMTP/IMAP—see `docs/deploy-guide.md`.

## Prerequisites

- DNS records:
  - MX: `upper.town` → `mail.upper.town`
  - A: `upper.town`, `mail.upper.town`, `mta-sts.upper.town`, `autoconfig.upper.town` → droplet IP
- Mox config and data directories on the server:
  - `/mnt/uppertown_production_webapp_volume/mox/config/` (mox.conf, domains.conf)
  - `/mnt/uppertown_production_webapp_volume/mox/data/`
- **Certs:** Kamal-proxy obtains certs via Let's Encrypt. The Mox container mounts the kamal-proxy cert cache; the entrypoint splits the autocert format into separate cert/key files for Mox. No separate cert tool needed.

## Setup

1. Copy `mox.conf.example` to the server as `mox.conf`:
   ```bash
   scp mox/mox.conf.example webapp@upper.town:/mnt/uppertown_production_webapp_volume/mox/config/mox.conf
   ```

2. Create `domains.conf` (e.g. via `mox quickstart` on the server, or manually). Place it in the same config directory.

## Deploy

Deploy webapp first (starts kamal-proxy with automatic TLS), then Mox:

```bash
bin/kamal deploy
bin/kamal deploy -c config/deploy-mox.yml
```

On first deploy, the cert for `mail.upper.town` may not exist yet (it's created on first HTTPS request). The entrypoint waits up to 5 minutes. If Mox fails to start, visit `https://mail.upper.town` to trigger cert generation, then restart: `bin/kamal app boot -c config/deploy-mox.yml`.

**Volume path:** The cert volume path in `deploy-mox.yml` assumes a volume named `kamal-proxy-config`. Kamal may use a different name (e.g. `webapp-proxy-config`). To find the actual path: `docker volume ls | grep proxy`, then `docker volume inspect <volume-name>`. Update the volumes section in `deploy-mox.yml` if needed.

## Ports

- **HTTP/HTTPS** (autoconfig, MTA-STS): Routed via kamal-proxy (80, 443)
- **SMTP/IMAP** (25, 587, 465, 143, 993): Mox binds directly. Published in deploy-mox.yml.

## Admin interface

The admin interface (domains, accounts, queue) is at https://mail.upper.town/admin/ (protected by the admin password from quickstart). The internal listener also exposes admin on localhost for SSH-tunnel access.
