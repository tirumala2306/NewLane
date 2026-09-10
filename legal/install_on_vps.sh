#!/usr/bin/env bash
# Run on the DigitalOcean server as root.
# Deploys legal HTML pages and enables /legal/ on api.newlanebrokers.com Nginx.

set -euo pipefail

LEGAL_DIR=/var/www/html/legal
NGINX_SITE=/etc/nginx/sites-available/api.newlanebrokers.com
REPO_URL="${REPO_URL:-https://github.com/tirumala2306/NewLane.git}"

mkdir -p "$LEGAL_DIR"

if command -v git >/dev/null 2>&1; then
  TMP=$(mktemp -d)
  git clone --depth 1 "$REPO_URL" "$TMP/NewLane"
  cp -f "$TMP/NewLane/legal/"*.html "$TMP/NewLane/legal/"*.css "$LEGAL_DIR/" 2>/dev/null || true
  rm -rf "$TMP"
else
  echo "git not found — copy legal/*.html and styles.css into $LEGAL_DIR manually"
  exit 1
fi

chown -R www-data:www-data "$LEGAL_DIR"
chmod -R a+rX "$LEGAL_DIR"

if [[ -f "$NGINX_SITE" ]] && ! grep -q 'location /legal/' "$NGINX_SITE"; then
  # Insert /legal/ location before the first "location /" in each server block that has one.
  python3 - <<'PY'
from pathlib import Path
path = Path("/etc/nginx/sites-available/api.newlanebrokers.com")
text = path.read_text()
snippet = """
    location /legal/ {
        alias /var/www/html/legal/;
        index index.html;
        try_files $uri $uri/ =404;
    }

"""
if "location /legal/" in text:
    print("Nginx /legal/ already present")
else:
    text = text.replace("    location / {", snippet + "    location / {", 1)
    # Also add to SSL server block if a second location / exists
    if text.count("    location / {") > 1 and text.count("location /legal/") == 1:
        # replace remaining first occurrence again carefully: add before every location / that isn't already preceded by legal
        parts = text.split("    location / {")
        rebuilt = parts[0]
        for i, part in enumerate(parts[1:], 1):
            if i == 1:
                rebuilt += "    location / {" + part
            else:
                if "location /legal/" not in rebuilt.split("server")[-1]:
                    rebuilt += snippet + "    location / {" + part
                else:
                    rebuilt += "    location / {" + part
        text = rebuilt
    path.write_text(text)
    print("Inserted /legal/ into Nginx config")
PY
fi

nginx -t
systemctl reload nginx

echo ""
echo "Deployed. Test:"
echo "  https://api.newlanebrokers.com/legal/privacy.html"
echo "  https://api.newlanebrokers.com/legal/support.html"
echo "  https://api.newlanebrokers.com/legal/terms.html"
