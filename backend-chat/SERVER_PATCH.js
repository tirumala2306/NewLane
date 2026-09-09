/**
 * MANUAL PATCH for /var/www/html/newlaneApp/server.js
 *
 * Add near your other route requires:
 *
 *   const chatRoutes = require('./routes/chatRoutes');
 *
 * After express app is created (after middleware), before app.listen:
 *
 *   try {
 *     require('./config/firebase').initFirebase();
 *   } catch (e) {
 *     console.warn('[firebase]', e.message);
 *   }
 *   app.use('/api/chat', chatRoutes);
 *
 * Endpoints:
 *   POST /api/chat/announcements
 *   POST /api/chat/dms
 *   POST /api/chat/seed-demo
 */
