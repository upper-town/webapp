# Mox Mail Server (Kamal + acme.sh TLS)

Mox runs alongside the webapp on the same droplet, using TLS certificates from acme.sh. See [docs/acme-sh-certificate-plan.md](../docs/acme-sh-certificate-plan.md) for the full setup.

## Prerequisites

- acme.sh installed on server (run `scripts/setup-acme-sh-on-server.sh`)
- DNS records:
  - MX: `upper.town` → `mail.upper.town`
  - A: `upper.town`, `mail.upper.town`, `mta-sts.upper.town`, `autoconfig.upper.town` → droplet IP
- Mox config and data directories on the server:
  - `/mnt/uppertown_production_webapp_volume/mox/config/` (mox.conf, domains.conf)
  - `/mnt/uppertown_production_webapp_volume/mox/data/`

## Setup

1. Run acme.sh setup on the server (one-time):
   ```bash
   scp scripts/setup-acme-sh-on-server.sh app@upper.town:
   ssh app@upper.town bash setup-acme-sh-on-server.sh
   ```

2. Copy `mox.conf.example` to the server as `mox.conf`:
   ```bash
   scp mox/mox.conf.example app@upper.town:/mnt/uppertown_production_webapp_volume/mox/config/mox.conf
   ```

3. Create `domains.conf` (e.g. via `mox quickstart` on the server, or manually). Place it in the same config directory.

## Deploy

Deploy webapp first (starts kamal-proxy with certs), then Mox:

```bash
source bin/kamal-certs-sync
bin/kamal deploy
bin/kamal deploy -c config/deploy-mox.yml
```

## Ports

- **HTTP/HTTPS** (autoconfig, MTA-STS): Routed via kamal-proxy (80, 443)
- **SMTP/IMAP** (25, 587, 465, 143, 993): Mox binds directly. Published in deploy-mox.yml.
