enum HistoryTap {
  chats,
  saved
}

extension HistoryTapExtension on HistoryTap {
  String get label {
    switch (this) {
      case HistoryTap.chats:
        return 'CHATS';
      case HistoryTap.saved:
        return'SAVED';
    }
  }
}