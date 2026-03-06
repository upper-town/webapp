#!/bin/sh
set -e

# Path where kamal-proxy volume is mounted
KAMAL_CERTS_DIR="/mnt/kamal-certs/"
MOX_DOMAIN="${MOX_TLS_DOMAIN:-mail.upper.town}"
MAX_WAIT=300
WAIT_INTERVAL=10
elapsed=0

# Find the autocert file (key+cert in one PEM) - structure is certs/<hash>/<domain> or <domain>+rsa
while [ $elapsed -lt $MAX_WAIT ]; do
  ACME_FILE=$(find "$KAMAL_CERTS_DIR" -type f \( -name "$MOX_DOMAIN" -o -name "$MOX_DOMAIN+rsa" \) 2>/dev/null | head -1)
  if [ -n "$ACME_FILE" ]; then
    break
  fi
  echo "Waiting for TLS cert ($MOX_DOMAIN)..."
  sleep $WAIT_INTERVAL
  elapsed=$((elapsed + WAIT_INTERVAL))
done

if [ -n "$ACME_FILE" ]; then
  MOX_TLS_DIR="/run/mox-tls"
  mkdir -p "$MOX_TLS_DIR"
  awk '/-----BEGIN.*PRIVATE KEY-----/,/-----END.*PRIVATE KEY-----/' "$ACME_FILE" > "$MOX_TLS_DIR/key.pem"
  awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "$ACME_FILE" > "$MOX_TLS_DIR/cert.pem"
  chmod 700 "$MOX_TLS_DIR"
  chmod 600 "$MOX_TLS_DIR/key.pem" "$MOX_TLS_DIR/cert.pem"
  export MOX_TLS_CERT_FILE="$MOX_TLS_DIR/cert.pem"
  export MOX_TLS_KEY_FILE="$MOX_TLS_DIR/key.pem"
  exec "$@"
else
  echo "ERROR: TLS cert for $MOX_DOMAIN not found after ${MAX_WAIT}s. Visit https://$MOX_DOMAIN to trigger cert generation, then restart Mox." >&2
  exit 1
fi
