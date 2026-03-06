# Deployment Guide

This guide walks you through setting up Upper Town (webapp + Mox mail server) on a single DigitalOcean droplet. Follow the steps in order for your first deploy.

**What gets deployed:**

- **Webapp** (Rails) + **PostgreSQL** (Kamal accessory) + **Mox** (mail server)
- TLS via **Kamal proxy** (automatic Let's Encrypt)
- Mox reuses Kamal's Let's Encrypt certs for SMTP/IMAP

## Table of contents

1. [Prerequisites](#1-prerequisites)
2. [Create the droplet](#2-create-the-droplet)
3. [Block storage volume](#3-block-storage-volume)
4. [Configure the droplet](#4-configure-the-droplet)
5. [DNS records](#5-dns-records)
6. [Secrets](#6-secrets)
7. [Mox setup](#7-mox-setup)
8. [Deploy](#8-deploy)
9. [Checklist](#9-checklist)
10. [References & appendix](#10-references--appendix)

## 1. Prerequisites

Before you start, ensure you have:

- **SSH keys** for droplet access (root and deploy user)
- **Bitwarden Secrets Manager** account and project for app secrets
- **Docker registry** reachable from your machine (e.g. `localhost:5555` or remote)
- **Domain** pointing to your droplet IP (A records required before deploy for Let's Encrypt)

### Generate SSH keys

```sh
eval "$(ssh-agent -s)"
ssh-add -l

ssh-keygen -t ed25519 -C "your-email@example.com"
ssh-add ~/.ssh/root-uppertown-production  # or your key path

cat ~/.ssh/root-uppertown-production.pub   # Add this to DigitalOcean
ssh-add -l
```

## 2. Create the droplet

**DigitalOcean setup:**

- **Service:** DigitalOcean
- **Project:** `uppertown-production`
- **Region:** San Francisco (SFO3) or your preference
- **VPC:** Optional; e.g. `uppertown-production-vpc` for network isolation
- **Image:** Ubuntu 24.04 (LTS) x64
- **Plan:** Shared CPU Basic, Premium AMD — 8 GB RAM / 2 CPUs
- **Storage:** 100 GB NVMe SSD
- **Authentication:** SSH key (`root-uppertown-production.pub`)
- **Hostname:** Set to `upper.town` (DigitalOcean sets PTR record automatically)

Optional: Add block storage volume later (`uppertown-production-webapp-volume`, 100 GB).

## 3. Block storage volume

The deploy configs expect a mounted volume at:

```
/mnt/uppertown_production_webapp_volume/
```

1. Create a block storage volume in DigitalOcean
2. Attach it to your droplet
3. Format and mount it at the path above

The mount path typically includes the volume name (e.g. `uppertown_production_webapp_volume`). Create this directory structure **before** the first deploy.

## 4. Configure the droplet

SSH in as root and run these steps.

**Before you start:** Add an A record in your DNS (e.g. Namecheap) so `upper.town` points to your droplet's IP. Otherwise `ssh root@upper.town` won't resolve. You can use the droplet's IP directly instead (e.g. `ssh root@YOUR_DROPLET_IP`) for the initial setup.

### 4.1 Install Docker and basics

```sh
ssh -i ~/.ssh/root-uppertown-production root@upper.town

apt update
apt upgrade -y
apt install -y docker.io vim curl git
reboot
```

### 4.2 Configure SSH keepalive (optional)

Prevents SSH sessions from dropping. On your **local machine**, add to `~/.ssh/config`:

```
Host *
  ServerAliveInterval 60
  ServerAliveCountMax 10
```

On the **server**, edit `/etc/ssh/sshd_config`:

```
ClientAliveInterval 60
ClientAliveCountMax 10
PasswordAuthentication no
```

Then: `systemctl restart ssh.service`

### 4.3 Configure firewall

```sh
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow OpenSSH
ufw allow 25/tcp    # SMTP
ufw allow 587/tcp   # SMTP submission
ufw allow 465/tcp   # SMTPS
ufw allow 143/tcp   # IMAP
ufw allow 993/tcp   # IMAPS
ufw enable
ufw status
```

### 4.4 Create deploy user

Kamal deploys as a non-root user. Create `webapp` (or match `ssh.user` in `config/deploy.yml`):

```sh
useradd --create-home webapp
usermod --shell /usr/bin/bash webapp
passwd webapp

usermod -aG sudo webapp
usermod -aG docker webapp

su - webapp
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Add your **deploy** public key to `~/.ssh/authorized_keys` (e.g. `webapp-uppertown-production.pub`). This is the key Kamal uses—it can differ from the root key.

### 4.5 Create directories on the volume

Run as root or with sudo. Ownership must match the deploy user (`webapp`):

```sh
VOLUME="/mnt/uppertown_production_webapp_volume"

# Webapp
sudo mkdir -p $VOLUME/storage
sudo mkdir -p $VOLUME/postgres

# Mox
sudo mkdir -p $VOLUME/mox/config
sudo mkdir -p $VOLUME/mox/data

sudo chown -R webapp:webapp $VOLUME
```

## 5. DNS records

DNS is done in two stages: basic records before deploy, and domain-specific records (DKIM, TLSA, etc.) after Mox setup.

**Critical:** A records must point to your droplet **before** deploying. Kamal's Let's Encrypt validates domain ownership via HTTP.

### Namecheap setup

Domain List → **Manage** → **Advanced DNS**. Ensure the domain uses **BasicDNS** (or PremiumDNS). Use **Automatic TTL** for new records. Enable **DNSSEC** in the domain's DNS settings.

### Required before deploy

Add these records in Namecheap Advanced DNS. Replace `your-droplet-ip` with your droplet's IP.

**A record (root):**

| Type | Host | Value |
|------|------|-------|
| A | @ | your-droplet-ip |

**CNAME records (subdomains):** In Namecheap, "Host" is the subdomain only (e.g. `mail`, not `mail.upper.town`).

| Type | Host | Value |
|------|------|-------|
| CNAME | mail | upper.town |
| CNAME | mta-sts | mail.upper.town |
| CNAME | autoconfig | mail.upper.town |

**MX record:** Advanced DNS → Add New Record:

| Type | Host | Value | Priority |
|------|------|-------|----------|
| MX | @ | mail.upper.town | 10 |

**CAA record:**

| Type | Host | Value |
|------|------|-------|
| CAA | @ | 0 issue "letsencrypt.org" |

### Domain-specific records (after Mox setup)

Records like **DKIM**, **TLSA**, **SPF**, **DMARC**, and **MTA-STS** are generated by Mox and are unique to your deployment. You get them only after Mox setup, because:

- **DKIM keys** are created when you run `mox quickstart` (they go into `domains.conf`)
- **TLSA** (DANE) and other records depend on your Mox config and domain

**When to add them:** After you've run Mox quickstart (section 7) and have both `mox.conf` and `domains.conf` on the server. You can add these records before or after the first deploy; mail deliverability improves once they're in place.

**To get the records:** The output includes SRV records (for email client autodiscovery), TLSA (DANE), and TXT records (SPF, DKIM, DMARC, MTA-STS, TLSRPT). Add everything from the output.

```bash
ssh webapp@upper.town
docker run --rm \
  -v /mnt/uppertown_production_webapp_volume/mox/config:/mox/config \
  r.xmox.nl/mox:v0.0.15 \
  mox config dnsrecords upper.town
```

Add the output to your DNS provider. Then verify:

```bash
docker run --rm \
  -v /mnt/uppertown_production_webapp_volume/mox/config:/mox/config \
  r.xmox.nl/mox:v0.0.15 \
  mox config dnscheck upper.town
```

**After Mox is deployed**, use Kamal aliases:

```bash
bin/kamal dnsrecords -c config/deploy-mox.yml
bin/kamal dnscheck -c config/deploy-mox.yml
```

**Namecheap:** Add the domain-specific records in Advanced DNS. For TXT records with long values (e.g. DKIM), Namecheap may split them across multiple quoted strings—use the exact format from `mox config dnsrecords`. SRV records use Host `_service._protocol` (e.g. `_submissions._tcp`). Changes typically propagate within 30 minutes.

## 6. Secrets

The webapp uses [Kamal secrets](https://kamal-deploy.org/docs/commands/secrets) with Bitwarden Secrets Manager.

```bash
export BWS_ACCESS_TOKEN="your-bitwarden-secrets-manager-token"
export BWS_PROJECT_ID="your-project-id"
```

Secrets are loaded from `.kamal/secrets-common`.

## 7. Mox setup

Mox needs `mox.conf` and `domains.conf` before it can run.

### 7.1 Create domains.conf (quickstart)

**Important:** Quickstart requires an *empty* config directory. It fails if `mox.conf` already exists (it uses exclusive-create for all files). Run quickstart first, then overwrite `mox.conf` with our config.

```bash
ssh webapp@upper.town
# Ensure config dir is empty (or only has our mox.conf.example ready to copy after)
# If you previously ran quickstart and have partial files, remove them first:
# rm -rf /mnt/uppertown_production_webapp_volume/mox/config/*

docker run --rm \
  -v /mnt/uppertown_production_webapp_volume/mox/config:/mox/config \
  -v /mnt/uppertown_production_webapp_volume/mox/data:/mox/data \
  r.xmox.nl/mox:v0.0.15 \
  mox quickstart -hostname mail.upper.town -skipdial admin@upper.town 0
```

Quickstart writes to `config/mox.conf` and `config/domains.conf` relative to the image's working directory (`/mox`), so the config volume must be mounted at `/mox/config` (not `/config`).

Flags:
- `-hostname mail.upper.town` — Use our mail hostname (avoids container hostname like `6d5cd577cede.upper.town`)
- `-skipdial` — Skip SMTP port 25 connectivity check (often blocked on cloud providers)
- `0` — Run as root UID (the container has no `mox` user)

Quickstart may warn about DNSSEC or outgoing SMTP; these are non-fatal. Output is also written to `quickstart.log` in the container's `/mox/` directory (not in the config volume).

Quickstart creates files as root. Fix ownership so the deploy user can manage config and data:

```bash
sudo chown -R webapp:webapp /mnt/uppertown_production_webapp_volume/mox/config
sudo chown -R webapp:webapp /mnt/uppertown_production_webapp_volume/mox/data
```

Quickstart creates `domains.conf`, prints admin/account passwords (save them), and prints DNS records. Then overwrite `mox.conf` with the project's config:

```bash
scp mox/mox.conf.example webapp@upper.town:/mnt/uppertown_production_webapp_volume/mox/config/mox.conf
```

**Next:** Run `mox config dnsrecords upper.town` to get the full list of domain-specific records (DKIM, TLSA, etc.) and add them to your DNS provider. See [Domain-specific records (after Mox setup)](#domain-specific-records-after-mox-setup).

**Before deploy** (run on the server):

```bash
ssh webapp@upper.town
docker run --rm \
  -v /mnt/uppertown_production_webapp_volume/mox/config:/mox/config \
  -v /mnt/uppertown_production_webapp_volume/mox/data:/mox/data \
  r.xmox.nl/mox:v0.0.15 \
  mox config dnsrecords upper.town
```

**After deploy** (from project root):

```bash
bin/kamal dnsrecords -c config/deploy-mox.yml
```

**Recovery from partial quickstart:** If you have `dkim/` and `hostkeys/` but no `domains.conf` (e.g. because `mox.conf` existed before quickstart), remove the partial contents and run quickstart again on an empty config:

```bash
ssh webapp@upper.town
rm -rf /mnt/uppertown_production_webapp_volume/mox/config/*
# Also clear data if quickstart created partial account data:
rm -rf /mnt/uppertown_production_webapp_volume/mox/data/*
# Then run the quickstart command above
```

## 8. Deploy

### TLS certificates

**Kamal proxy (HTTP/HTTPS):** Handles TLS automatically via Let's Encrypt. No manual setup.

**Mox (SMTP/IMAP):** Reuses Kamal's Let's Encrypt certs. Kamal-proxy stores certs in a Docker volume; Mox mounts that volume and an entrypoint splits the format for Mox.

**How it works:** Kamal-proxy obtains certs via ACME and stores them in `kamal-proxy-config`. Mox mounts that volume and splits the autocert PEM into separate cert/key files. Each host (`upper.town`, `mail.upper.town`, etc.) gets its own cert on first HTTPS request. Renewal is automatic; Mox sees updated certs on container restart. See [mox/README.md](../mox/README.md).

### Deploy commands

From the project root, with Bitwarden env vars set:

```bash
# Use sudo if Docker on your machine requires it
sudo env HOME=$HOME USER=$USER LOGNAME=$USER bash
export BWS_ACCESS_TOKEN=...
export BWS_PROJECT_ID=...

# 1. Deploy webapp (PostgreSQL + Kamal proxy with TLS)
bin/kamal setup   # First time only
bin/kamal deploy  # Subsequent deploys

# 2. Deploy Mox (reuses Kamal's Let's Encrypt certs)
bin/kamal deploy -c config/deploy-mox.yml
```

**`setup` vs `deploy`:** Use `bin/kamal setup` for the first deploy only—it bootstraps servers, installs Docker if needed, and starts kamal-proxy. For all later deploys, use `bin/kamal deploy`.

### First deploy: certificate bootstrap

The cert for `mail.upper.town` is created on the first HTTPS request. If Mox fails to start (entrypoint times out after 5 minutes):

1. Visit `https://mail.upper.town` to trigger ACME cert generation
2. Restart Mox: `bin/kamal app boot -c config/deploy-mox.yml`

## 9. Checklist

Before first deploy:

- [ ] Droplet created and reachable via SSH
- [ ] Block volume attached and mounted at `/mnt/uppertown_production_webapp_volume/`
- [ ] Directories created (storage, postgres, mox/config, mox/data)
- [ ] DNS: A records for upper.town, mail, mta-sts, autoconfig
- [ ] DNS: MX record upper.town → mail.upper.town
- [ ] DNS: CAA record for Let's Encrypt (0 issue "letsencrypt.org")
- [ ] Mox: mox.conf and domains.conf in place
- [ ] Secrets configured (BWS_ACCESS_TOKEN, BWS_PROJECT_ID)
- [ ] Deploy user (webapp) exists with SSH key in authorized_keys
- [ ] Docker registry available (config/deploy.yml)

After Mox setup (before or after deploy):

- [ ] DNS: Domain-specific records (DKIM, TLSA, SPF, DMARC, MTA-STS) from `mox config dnsrecords upper.town`

## 10. References & appendix

### References

- [Mox README](../mox/README.md)
- [Kamal documentation](https://kamal-deploy.org/docs/)
- [Kamal Proxy Configuration](https://kamal-deploy.org/docs/configuration/proxy/)
- [Mox Config Reference](https://www.xmox.nl/config/)

### Build and deploy (local)

```sh
sudo env HOME=$HOME USER=$USER LOGNAME=$USER bash
export BWS_ACCESS_TOKEN=...
export BWS_PROJECT_ID=...

bin/kamal setup   # First time only
bin/kamal deploy
```

### SSH helpers

```sh
# Check if SSH host exists
ssh-keygen -F example.com

# Remove SSH key from known_hosts
ssh-keygen -R example.com
```

### GPG commit signing (optional)

```sh
gpg --list-secret-keys --keyid-format=long
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```
