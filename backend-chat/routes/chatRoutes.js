'use strict';

/**
 * Drop into: /var/www/html/newlaneApp/routes/chatRoutes.js
 *
 * Wire in server.js:
 *   const chatRoutes = require('./routes/chatRoutes');
 *   app.use('/api/chat', chatRoutes);
 *
 * If you have auth middleware (e.g. protect / verifyToken), attach it:
 *   router.post('/dms', protect, ensureDirectMessage);
 */

const express = require('express');
const {
  createAnnouncement,
  ensureDirectMessage,
  seedDemoChats,
} = require('../controllers/chatController');

const router = express.Router();

// Optional: require('../middleware/auth') protect — adjust path to your project.
let protect = (req, res, next) => next();
try {
  // Common NewLane-style middleware names — first existing wins.
  const candidates = [
    '../middleware/auth',
    '../middleware/authenticate',
    '../middleware/verifyToken',
    '../middleware/protect',
  ];
  for (const rel of candidates) {
    try {
      const mod = require(rel);
      protect = mod.protect || mod.authenticate || mod.verifyToken || mod || protect;
      if (typeof protect === 'function') break;
    } catch (_) {
      // try next
    }
  }
} catch (_) {
  // no auth middleware found — routes stay open (dev)
}

router.post('/announcements', protect, createAnnouncement);
router.post('/dms', protect, ensureDirectMessage);
router.post('/seed-demo', protect, seedDemoChats);

module.exports = router;
