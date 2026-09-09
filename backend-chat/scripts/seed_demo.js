'use strict';

/**
 * Local / CI seed using firebase-admin (no Express).
 *
 * Usage (from backend-chat/):
 *   npm install firebase-admin
 *   # place config/firebase-service-account.json
 *   node scripts/seed_demo.js [currentUserId]
 */

const path = require('path');
const fs = require('fs');
const admin = require('firebase-admin');

const keyPath = path.join(__dirname, '..', 'config', 'firebase-service-account.json');
if (!fs.existsSync(keyPath)) {
  console.error('Missing', keyPath);
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(keyPath)),
});

const db = admin.firestore();
const currentUserId = String(process.argv[2] || 'me');
const peerId = 'user_sarah';
const now = admin.firestore.FieldValue.serverTimestamp();

async function main() {
  const announcementRef = db.collection('chats').doc('announcement_office');
  await announcementRef.set(
    {
      type: 'announcement',
      title: 'Office Announcement',
      participantIds: [currentUserId, 'office_admin'],
      lastMessage: 'Team meeting this Friday at 10:00 AM',
      lastMessageAt: now,
      lastMessageSenderId: 'office_admin',
      pinnedBy: [currentUserId],
      unreadCounts: { [currentUserId]: 1 },
      avatarUrl: '',
      peerUserId: '',
      isOnline: false,
    },
    { merge: true },
  );

  await announcementRef.collection('messages').add({
    text: 'Team meeting this Friday at 10:00 AM',
    senderId: 'office_admin',
    senderName: 'Office Admin',
    senderAvatar: '',
    createdAt: now,
    readBy: [],
  });

  const dmId = `dm_${[currentUserId, peerId].sort().join('_')}`;
  const dmRef = db.collection('chats').doc(dmId);
  await dmRef.set(
    {
      type: 'direct',
      title: 'Sarah Johnson',
      participantIds: [currentUserId, peerId],
      lastMessage: 'Perfect, see you all there!',
      lastMessageAt: now,
      lastMessageSenderId: peerId,
      pinnedBy: [],
      unreadCounts: { [currentUserId]: 1, [peerId]: 0 },
      avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      peerUserId: peerId,
      isOnline: true,
    },
    { merge: true },
  );

  for (const msg of [
    {
      text: "Don't forget about the team meeting this Friday at 10 AM!",
      senderId: peerId,
      senderName: 'Sarah Johnson',
    },
    { text: "I'll be there!", senderId: currentUserId, senderName: 'You' },
    {
      text: 'Perfect, see you all there!',
      senderId: peerId,
      senderName: 'Sarah Johnson',
    },
  ]) {
    await dmRef.collection('messages').add({
      text: msg.text,
      senderId: msg.senderId,
      senderName: msg.senderName,
      senderAvatar:
        msg.senderId === peerId
          ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200'
          : '',
      createdAt: now,
      readBy: msg.senderId === currentUserId ? [currentUserId] : [],
    });
  }

  console.log('Seeded announcement_office and', dmId, 'for user', currentUserId);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
