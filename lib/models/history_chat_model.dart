class HistoryChatModel {
  final int id;
  final bool isPinned;
  final bool isSaved;
  final DateTime lastMessageAt;
  final String title;
  final String content;

  HistoryChatModel({
    required this.id,
    required this.isPinned,
    required this.isSaved,
    required this.lastMessageAt,
    required this.title,
    required this.content,
  });
}
