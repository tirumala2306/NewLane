'use strict';

/**
 * Drop into: /var/www/html/newlaneApp/config/firebase.js
 *
 * Requires: config/firebase-service-account.json
 * (Firebase Console → Project settings → Service accounts → Generate new private key)
 */

const path = require('path');
const fs = require('fs');
const admin = require('firebase-admin');

let initialized = false;

function initFirebase() {
  if (initialized) {
    return admin;
  }

  const keyPath = path.join(__dirname, 'firebase-service-account.json');
  if (!fs.existsSync(keyPath)) {
    console.warn(
      '[firebase] missing config/firebase-service-account.json — chat admin disabled',
    );
    return null;
  }

  const serviceAccount = require(keyPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  initialized = true;
  console.log('[firebase] admin ready');
  return admin;
}

function getDb() {
  const app = initFirebase();
  if (!app) {
    throw new Error('Firebase Admin is not configured');
  }
  return admin.firestore();
}

module.exports = {
  initFirebase,
  getDb,
  admin,
};
