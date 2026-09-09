enum ChatFilter { all, announcements, pinned }

extension ChatFilterLabel on ChatFilter {
  String get label => switch (this) {
    ChatFilter.all => 'All Chats',
    ChatFilter.announcements => 'Announcements',
    ChatFilter.pinned => 'Pinned',
  };
}
