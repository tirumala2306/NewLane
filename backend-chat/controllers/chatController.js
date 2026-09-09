'use strict';

/**
 * Drop into: /var/www/html/newlaneApp/controllers/chatController.js
 *
 * Creates office announcement channels and ensures 1:1 DM rooms in Firestore.
 * Shape matches Flutter FirestoreChatRemoteDataSource.
 */

const { getDb, admin } = require('../config/firebase');

function asStringId(value) {
  return String(value);
}

/**
 * POST /api/chat/announcements
 * body: { officeId, title?, participantIds: number[]|string[], message? }
 */
async function createAnnouncement(req, res) {
  try {
    const db = getDb();
    const {
      officeId,
      title = 'Office Announcement',
      participantIds = [],
      message = '',
    } = req.body || {};

    const ids = (Array.isArray(participantIds) ? participantIds : [])
      .map(asStringId)
      .filter(Boolean);

    if (ids.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'participantIds is required',
      });
    }

    const unreadCounts = {};
    ids.forEach((id) => {
      unreadCounts[id] = message ? 1 : 0;
    });

    const chatRef = db.collection('chats').doc();
    const now = admin.firestore.FieldValue.serverTimestamp();
    const lastMessage =
      typeof message === 'string' && message.trim()
        ? message.trim()
        : '';

    await chatRef.set({
      type: 'announcement',
      title: String(title),
      officeId: officeId != null ? asStringId(officeId) : '',
      participantIds: ids,
      lastMessage,
      lastMessageAt: now,
      lastMessageSenderId: 'office_admin',
      pinnedBy: ids.slice(),
      unreadCounts,
      avatarUrl: '',
      peerUserId: '',
      isOnline: false,
      createdAt: now,
    });

    if (lastMessage) {
      await chatRef.collection('messages').add({
        text: lastMessage,
        senderId: 'office_admin',
        senderName: 'Office Admin',
        senderAvatar: '',
        createdAt: now,
        readBy: [],
      });
    }

    return res.status(201).json({
      success: true,
      message: 'Announcement chat created',
      data: { chatId: chatRef.id },
    });
  } catch (error) {
    console.error('[chat] createAnnouncement', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Failed to create announcement',
    });
  }
}

/**
 * POST /api/chat/dms
 * body: { peerUserId, peerName, peerAvatar?, currentUserId?, currentUserName? }
 * Uses authenticated agent id when middleware sets req.user / req.agent.
 */
async function ensureDirectMessage(req, res) {
  try {
    const db = getDb();
    const authUser = req.user || req.agent || {};
    const currentUserId = asStringId(
      req.body.currentUserId || authUser.id || authUser.agentId || '',
    );
    const currentUserName =
      req.body.currentUserName ||
      authUser.fullName ||
      authUser.name ||
      'You';
    const {
      peerUserId,
      peerName,
      peerAvatar = '',
    } = req.body || {};

    if (!currentUserId || !peerUserId || !peerName) {
      return res.status(400).json({
        success: false,
        message: 'currentUserId, peerUserId, and peerName are required',
      });
    }

    const peerId = asStringId(peerUserId);
    if (peerId === currentUserId) {
      return res.status(400).json({
        success: false,
        message: 'Cannot create a DM with yourself',
      });
    }

    const pairKey = [currentUserId, peerId].sort().join('_');
    const chatId = `dm_${pairKey}`;
    const chatRef = db.collection('chats').doc(chatId);
    const existing = await chatRef.get();

    if (existing.exists) {
      return res.status(200).json({
        success: true,
        message: 'DM already exists',
        data: { chatId },
      });
    }

    const now = admin.firestore.FieldValue.serverTimestamp();
    await chatRef.set({
      type: 'direct',
      title: String(peerName),
      participantIds: [currentUserId, peerId],
      lastMessage: '',
      lastMessageAt: now,
      lastMessageSenderId: '',
      pinnedBy: [],
      unreadCounts: {
        [currentUserId]: 0,
        [peerId]: 0,
      },
      avatarUrl: peerAvatar || '',
      peerUserId: peerId,
      peerNames: {
        [currentUserId]: currentUserName,
        [peerId]: String(peerName),
      },
      isOnline: false,
      createdAt: now,
    });

    return res.status(201).json({
      success: true,
      message: 'DM created',
      data: { chatId },
    });
  } catch (error) {
    console.error('[chat] ensureDirectMessage', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Failed to create DM',
    });
  }
}

/**
 * POST /api/chat/seed-demo
 * body: { currentUserId } — seeds announcement + sample DM for Flutter testing
 */
async function seedDemoChats(req, res) {
  try {
    const db = getDb();
    const currentUserId = asStringId(
      (req.body && req.body.currentUserId) ||
        (req.user && req.user.id) ||
        'me',
    );
    const peerId = 'user_sarah';
    const now = admin.firestore.FieldValue.serverTimestamp();

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

    const messages = [
      {
        text: "Don't forget about the team meeting this Friday at 10 AM!",
        senderId: peerId,
        senderName: 'Sarah Johnson',
      },
      {
        text: "I'll be there!",
        senderId: currentUserId,
        senderName: 'You',
      },
      {
        text: 'Perfect, see you all there!',
        senderId: peerId,
        senderName: 'Sarah Johnson',
      },
    ];

    for (const msg of messages) {
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

    return res.status(201).json({
      success: true,
      message: 'Demo chats seeded',
      data: {
        announcementChatId: 'announcement_office',
        dmChatId: dmId,
        currentUserId,
      },
    });
  } catch (error) {
    console.error('[chat] seedDemoChats', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Failed to seed demo chats',
    });
  }
}

module.exports = {
  createAnnouncement,
  ensureDirectMessage,
  seedDemoChats,
};
