'use strict';

/**
 * One-time install helper for the VPS.
 *
 * On the server:
 *   cd /var/www/html/newlaneApp
 *   # copy backend-chat/* into place (see INSTALL_STEPS below)
 *   npm install firebase-admin
 *   # place firebase-service-account.json in config/
 *   # patch server.js then restart
 *
 * INSTALL_STEPS
 * 1. Copy config/firebase.js        → config/firebase.js
 * 2. Copy controllers/chatController.js → controllers/chatController.js
 * 3. Copy routes/chatRoutes.js      → routes/chatRoutes.js
 * 4. npm install firebase-admin
 * 5. Add near other routes in server.js:
 *      const chatRoutes = require('./routes/chatRoutes');
 *      app.use('/api/chat', chatRoutes);
 * 6. require('./config/firebase').initFirebase(); at startup (optional)
 * 7. pm2 restart / systemctl restart your node process
 */

const fs = require('fs');
const path = require('path');

function printPatchHint() {
  const hint = `
--- server.js patch ---
const chatRoutes = require('./routes/chatRoutes');
try { require('./config/firebase').initFirebase(); } catch (e) { console.warn(e.message); }
app.use('/api/chat', chatRoutes);
--- end patch ---
`;
  console.log(hint);
}

if (require.main === module) {
  printPatchHint();
  const key = path.join(__dirname, 'config', 'firebase-service-account.json.example');
  if (!fs.existsSync(key)) {
    console.log('Place your real service account at config/firebase-service-account.json');
  }
}

module.exports = { printPatchHint };
