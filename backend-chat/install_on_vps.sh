#!/usr/bin/env bash
# Run ON the VPS as root (or deploy user) from /var/www/html/newlaneApp
# after copying the backend-chat folder contents into the app.
#
# Example from your laptop (Win SCP / scp):
#   scp -r backend-chat/* root@159.223.149.54:/var/www/html/newlaneApp/
# Then on server:
#   cd /var/www/html/newlaneApp && bash install_on_vps.sh
# Or if you kept files under backend-chat/:
#   bash backend-chat/install_on_vps.sh

set -euo pipefail

APP_ROOT="${APP_ROOT:-/var/www/html/newlaneApp}"
cd "$APP_ROOT"

echo "[1/5] npm install firebase-admin"
npm install firebase-admin --save

SRC_DIR="$APP_ROOT"
if [[ -d "$APP_ROOT/backend-chat" ]]; then
  SRC_DIR="$APP_ROOT/backend-chat"
fi

echo "[2/5] sync chat modules from $SRC_DIR"
mkdir -p config controllers routes
cp -f "$SRC_DIR/config/firebase.js" config/firebase.js
cp -f "$SRC_DIR/controllers/chatController.js" controllers/chatController.js
cp -f "$SRC_DIR/routes/chatRoutes.js" routes/chatRoutes.js
if [[ -f "$SRC_DIR/config/firebase-service-account.json.example" ]]; then
  cp -n "$SRC_DIR/config/firebase-service-account.json.example" \
    config/firebase-service-account.json.example || true
fi

echo "[3/5] service account check"
if [[ ! -f config/firebase-service-account.json ]]; then
  echo "MISSING: config/firebase-service-account.json"
  echo "Download from Firebase Console → Project settings → Service accounts → Generate new private key"
  echo "Save as: $APP_ROOT/config/firebase-service-account.json"
  exit 1
fi

echo "[4/5] patch server.js if chat routes not wired"
if ! grep -q "routes/chatRoutes" server.js 2>/dev/null; then
  # Insert require near top after other requires is hard; append safe boot patch before listen if possible.
  if grep -q "app.listen" server.js; then
    # shellcheck disable=SC2016
    perl -i -0pe 's/(app\.listen)/try { require(".\/config\/firebase").initFirebase(); } catch (e) { console.warn("[firebase]", e.message); }\nconst chatRoutes = require(".\/routes\/chatRoutes");\napp.use("\/api\/chat", chatRoutes);\n\n$1/s' server.js
    echo "Patched server.js with /api/chat"
  else
    echo "Could not auto-patch server.js — add manually:"
    echo '  try { require("./config/firebase").initFirebase(); } catch (e) { console.warn(e.message); }'
    echo '  const chatRoutes = require("./routes/chatRoutes");'
    echo '  app.use("/api/chat", chatRoutes);'
  fi
else
  echo "server.js already references chatRoutes"
fi

echo "[5/5] restart node"
if command -v pm2 >/dev/null 2>&1; then
  pm2 restart all || pm2 restart newlane || true
elif systemctl list-units --type=service | grep -qi newlane; then
  systemctl restart newlane || true
else
  echo "Restart your Node process manually (pm2 / systemd / forever)."
fi

echo "OK — test seed:"
echo "  curl -X POST http://127.0.0.1:5000/api/chat/seed-demo -H 'Content-Type: application/json' -d '{\"currentUserId\":\"me\"}'"
