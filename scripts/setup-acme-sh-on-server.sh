#!/bin/bash
# Run on the server (app@upper.town) to install acme.sh and set up cert management.
# Usage: scp scripts/setup-acme-sh-on-server.sh app@upper.town: && ssh app@upper.town bash setup-acme-sh-on-server.sh
#
# Prerequisites: DNS A records for upper.town, mail.upper.town, mta-sts.upper.town, autoconfig.upper.town
# Port 80 must be free for standalone mode (stop kamal-proxy first: docker stop kamal-proxy)
#
# Optional: USE_STAGING=1 to test with Let's Encrypt staging (avoids rate limits during testing)

set -e

CERT_DIR="/mnt/uppertown_production_webapp_volume/certs"
DOMAINS="-d upper.town -d mail.upper.town -d mta-sts.upper.town -d autoconfig.upper.town"
STAGING_FLAG=""
[[ -n "$USE_STAGING" ]] && STAGING_FLAG="--staging"

echo "=== 1. Install acme.sh ==="
curl -s https://get.acme.sh | sh -s email=admin@upper.town
export PATH="$HOME/.acme.sh:$PATH"

echo "=== 2. Create cert directory ==="
sudo mkdir -p "$CERT_DIR"
sudo chown "$(whoami):$(whoami)" "$CERT_DIR"

echo "=== 3. Issue certificate (standalone, port 80 must be free) ==="
[[ -n "$STAGING_FLAG" ]] && echo "Using Let's Encrypt STAGING (cert will not be trusted)"
acme.sh --issue $DOMAINS --standalone $STAGING_FLAG

echo "=== 4. Create reload script ==="
mkdir -p ~/bin
cat > ~/bin/acme-reload-upper-town << 'RELOAD'
#!/bin/sh
# Filter matches Kamal container names (e.g. mox-web-1)
for cid in $(docker ps -q -f "name=mox-web" 2>/dev/null); do
  docker restart "$cid"
done
logger -t acme-sh "Upper Town cert renewed; Mox restarted. Consider: bin/kamal deploy"
RELOAD
chmod +x ~/bin/acme-reload-upper-town
export PATH="$HOME/bin:$PATH"

echo "=== 5. Install cert to shared path ==="
acme.sh --install-cert \
  -d upper.town \
  --fullchain-file "$CERT_DIR/fullchain.pem" \
  --key-file "$CERT_DIR/privkey.pem" \
  --reloadcmd "acme-reload-upper-town"

echo "=== 6. Add PATH to shell profile ==="
PATH_LINE='export PATH="$HOME/bin:$HOME/.acme.sh:$PATH"'
for rc in .bashrc .profile; do
  if [[ -f "$HOME/$rc" ]] && ! grep -q 'acme.sh' "$HOME/$rc" 2>/dev/null; then
    echo "$PATH_LINE" >> "$HOME/$rc"
    echo "Added PATH to ~/$rc"
    break
  fi
done

echo "=== Done ==="
echo "Certs are at $CERT_DIR"
echo "Deploy: source bin/kamal-certs-sync && bin/kamal deploy && bin/kamal deploy -c config/deploy-mox.yml"
