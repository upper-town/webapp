# Plan: acme.sh for Shared TLS Certificates (Kamal + Mox)

This document describes how to use **acme.sh** as the certificate manager for both Kamal (webapp) and Mox on a single DigitalOcean Droplet. acme.sh obtains certificates via Let's Encrypt ACME and deploys them to a shared directory that both services use.

**Prerequisites:** Read `docs/kamal-mox-shared-certificates-plan.md` for the overall architecture. This plan implements the "Third Tool" approach with acme.sh.

---

## Overview

| Step | What |
|------|------|
| 1 | Install acme.sh on the server |
| 2 | Create shared cert directory |
| 3 | Issue certificate (all domains in one SAN cert) |
| 4 | Install cert to shared path with reloadcmd |
| 5 | Configure Mox to use cert files |
| 6 | Configure Kamal to use certs via secrets (pre-deploy hook) |
| 7 | Set up renewal (cron + reloadcmd) |

---

## 1. Install acme.sh on the Server

SSH to the droplet and install acme.sh for the `app` user (or root, depending on your setup):

```bash
ssh app@upper.town

# Install acme.sh (runs as current user, no sudo)
curl https://get.acme.sh | sh -s email=admin@upper.town

# Reload shell or source
source ~/.bashrc   # or ~/.profile
```

acme.sh installs to `~/.acme.sh/` and adds a cron job for automatic renewal.

---

## 2. Create Shared Cert Directory

Create a directory that both Mox and Kamal will use. This lives on the same volume as your app data:

```bash
sudo mkdir -p /mnt/uppertown_production_webapp_volume/certs
sudo chown app:app /mnt/uppertown_production_webapp_volume/certs
```

We'll use:
- `fullchain.pem` — certificate + intermediate chain (for TLS)
- `privkey.pem` — private key

---

## 3. Issue Certificate (Initial Run)

**Before running:** Ensure DNS A records point to the droplet:
- `upper.town` → droplet IP
- `mail.upper.town` → droplet IP
- `mta-sts.upper.town` → droplet IP
- `autoconfig.upper.town` → droplet IP

**Port 80 must be free** for the HTTP-01 challenge. If kamal-proxy is running, stop it temporarily:

```bash
docker stop kamal-proxy   # or whatever the proxy container is named
```

**First-time testing:** Use `USE_STAGING=1` to avoid Let's Encrypt rate limits: `USE_STAGING=1 bash scripts/setup-acme-sh-on-server.sh`

Issue a single SAN certificate for all domains:

```bash
acme.sh --issue \
  -d upper.town \
  -d mail.upper.town \
  -d mta-sts.upper.town \
  -d autoconfig.upper.town \
  --standalone
```

If port 80 is in use, use **DNS-01** instead (requires DNS API credentials, e.g. DigitalOcean):

```bash
export DO_API_TOKEN="your-digitalocean-token"
acme.sh --issue \
  -d upper.town \
  -d mail.upper.town \
  -d mta-sts.upper.town \
  -d autoconfig.upper.town \
  --dns dns_do
```

---

## 4. Install Cert to Shared Path with Reloadcmd

After the cert is issued, install it to the shared directory. The `--reloadcmd` runs after each renewal:

```bash
CERT_DIR="/mnt/uppertown_production_webapp_volume/certs"

acme.sh --install-cert \
  -d upper.town \
  --fullchain-file "$CERT_DIR/fullchain.pem" \
  --key-file "$CERT_DIR/privkey.pem" \
  --reloadcmd "acme-reload-upper-town"
```

**Important:** `--reloadcmd` accepts a command name. We'll create a script `acme-reload-upper-town` that restarts Mox (and optionally triggers a Kamal proxy refresh).

Create the reload script:

```bash
# ~/bin/acme-reload-upper-town
#!/bin/sh
# Restart Mox to pick up renewed cert (container name may vary: mox-web-1, mox_web_1, etc.)
for cid in $(docker ps -q -f "name=mox" 2>/dev/null); do docker restart "$cid"; done
# Kamal proxy: certs are baked in at deploy time; redeploy to refresh.
logger -t acme-sh "Upper Town cert renewed; Mox restarted. Consider: bin/kamal deploy"
```

Make it executable and ensure it's in PATH:

```bash
mkdir -p ~/bin
# ... create script ...
chmod +x ~/bin/acme-reload-upper-town
export PATH="$HOME/bin:$PATH"
```

Then re-run `--install-cert` so the reloadcmd is saved in acme.sh's config. The reloadcmd is persisted and will run on every renewal.

---

## 5. Configure Mox

### 5.1 Update deploy-mox.yml

Mount the shared cert directory and remove the kamal-proxy volume mount. Switch to custom SSL (see step 6 for both deploy configs).

```yaml
# config/deploy-mox.yml
volumes:
  - /mnt/uppertown_production_webapp_volume/mox/config:/config
  - /mnt/uppertown_production_webapp_volume/mox/data:/data
  - /mnt/uppertown_production_webapp_volume/certs:/mnt/certs:ro
```

### 5.2 Update mox.conf

Point KeyCerts at the mounted cert files. No entrypoint split needed.

```sconf
Listeners:
  public:
    Hostname: mail.upper.town
    TLS:
      KeyCerts:
        - CertFile: /mnt/certs/fullchain.pem
          KeyFile: /mnt/certs/privkey.pem
    # ... SMTP, IMAP, etc.
```

### 5.3 Mox Image

Use the official Mox image directly—no custom Dockerfile or entrypoint needed:

```yaml
image: r.xmox.nl/mox:v0.0.15
```

---

## 6. Configure Kamal (Webapp and Mox Proxy)

Kamal's proxy expects cert content via secrets. Use `proxy.ssl: { certificate_pem:, private_key_pem: }` in both `deploy.yml` and `deploy-mox.yml`.

### 6.1 Pre-deploy Hook: Fetch Certs from Server

Create a script that populates Kamal secrets from the server. Run this before `bin/kamal deploy`:

```bash
# bin/kamal-certs-sync
#!/bin/sh
# Fetches certs from server and exports for Kamal secrets.
# Usage: source bin/kamal-certs-sync && bin/kamal deploy

set -e
SERVER="${KAMAL_CERTS_SERVER:-app@upper.town}"
CERT_DIR="/mnt/uppertown_production_webapp_volume/certs"

export CERTIFICATE_PEM=$(ssh "$SERVER" "cat $CERT_DIR/fullchain.pem")
export PRIVATE_KEY_PEM=$(ssh "$SERVER" "cat $CERT_DIR/privkey.pem")

echo "Certs fetched from $SERVER"
```

Or use `.kamal/secrets` with dynamic resolution (if your Kamal version supports it):

```
# .kamal/secrets
CERTIFICATE_PEM=$(ssh app@upper.town "cat /mnt/uppertown_production_webapp_volume/certs/fullchain.pem")
PRIVATE_KEY_PEM=$(ssh app@upper.town "cat /mnt/uppertown_production_webapp_volume/certs/privkey.pem")
```

### 6.2 deploy.yml

```yaml
proxy:
  ssl:
    certificate_pem: CERTIFICATE_PEM
    private_key_pem: PRIVATE_KEY_PEM
  host: upper.town
  # ... rest of proxy config
```

### 6.3 deploy-mox.yml

```yaml
proxy:
  ssl:
    certificate_pem: CERTIFICATE_PEM
    private_key_pem: PRIVATE_KEY_PEM
  hosts:
    - mail.upper.town
    - mta-sts.upper.town
    - autoconfig.upper.town
  app_port: 80
```

Both configs use the same cert (one SAN cert covers all domains).

### 6.4 Deploy Workflow

```bash
# From your dev machine
source bin/kamal-certs-sync
bin/kamal deploy
bin/kamal deploy -c config/deploy-mox.yml
```

---

## 7. Renewal

acme.sh installs a cron job at `~/.acme.sh/acme.sh --cron`. It runs daily and renews certs when they have < 30 days left.

On renewal:
1. acme.sh renews the cert
2. `--install-cert` copies new files to `/mnt/uppertown_production_webapp_volume/certs/`
3. `--reloadcmd` runs → restarts Mox

**Kamal proxy:** The proxy holds cert content from the last deploy. After acme.sh renews, the proxy still has the old cert. To refresh:
- **Option A:** Redeploy after renewal (manual or automated)
- **Option B:** Add to reloadcmd a script that SSHs from server to itself and triggers a Kamal proxy reboot (complex)
- **Option C:** Accept that the proxy cert may be up to 60 days old; Let's Encrypt certs are valid 90 days, so you have a 30-day renewal window. A monthly redeploy is usually enough.

---

## 8. Bootstrap Order (First-Time Setup)

1. **DNS:** Add A records for upper.town, mail.upper.town, mta-sts.upper.town, autoconfig.upper.town
2. **Stop proxy** (if running): `docker stop kamal-proxy`
3. **Install acme.sh** (step 1)
4. **Create cert dir** (step 2)
5. **Issue cert** (step 3)
6. **Install cert** (step 4)
7. **Create reload script** (step 4)
8. **Start proxy** (or deploy webapp): `bin/kamal deploy`
9. **Deploy Mox:** `bin/kamal deploy -c config/deploy-mox.yml`
10. **Configure Mox** (mox.conf, domains.conf) on the server

---

## 9. File Layout Summary

```
Server (upper.town)
├── ~/.acme.sh/
│   └── upper.town/           # acme.sh internal storage
├── /mnt/uppertown_production_webapp_volume/
│   ├── certs/               # Shared cert output (acme.sh --install-cert)
│   │   ├── fullchain.pem
│   │   └── privkey.pem
│   ├── mox/
│   │   ├── config/
│   │   └── data/
│   └── ...
└── ~/bin/acme-reload-upper-town
```

---

## 10. Checklist

- [ ] Install acme.sh on server
- [ ] Create `/mnt/uppertown_production_webapp_volume/certs`
- [ ] DNS A records for all four domains
- [ ] Issue cert (standalone or DNS-01)
- [ ] Install cert with --reloadcmd
- [ ] Create acme-reload-upper-town script
- [ ] Update deploy-mox.yml: volumes (certs), proxy.ssl (secrets)
- [ ] Update deploy.yml: proxy.ssl (secrets)
- [ ] Create bin/kamal-certs-sync
- [ ] Update mox.conf: KeyCerts paths
- [x] Use official Mox image (no custom Dockerfile)
- [ ] Deploy webapp, then Mox
- [ ] Verify TLS: https://upper.town, https://mail.upper.town, SMTP/IMAP

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| `Certs not found` from kamal-certs-sync | acme.sh not run or certs not installed | Run `scripts/setup-acme-sh-on-server.sh` on server |
| `proxy/ssl: should be a boolean` | Kamal &lt; 2.5 | Upgrade: `bundle update kamal` |
| Port 80 in use during acme.sh --issue | kamal-proxy or other service | Stop proxy: `docker stop kamal-proxy` |
| Rate limit from Let's Encrypt | Too many failed/staging requests | Use `USE_STAGING=1` for testing; wait before retry |
| Mox container not found by reloadcmd | Container name differs | Check `docker ps`; adjust filter in `acme-reload-upper-town` |

---

## References

- [acme.sh: How to issue a cert](https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert)
- [acme.sh: Using reloadcmd](https://github.com/acmesh-official/acme.sh/wiki/Using-pre-hook-post-hook-renew-hook-reloadcmd)
- [Kamal: Custom SSL certificate](https://kamal-deploy.org/docs/configuration/proxy/)
- [Mox: Existing TLS certificates](https://www.xmox.nl/faq/)
