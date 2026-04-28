class ChatSession {
  final String sessionId;
  final String title;
  final String createdAt;
  final String lastActiveAt;

  ChatSession({
    required this.sessionId,
    required this.title,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['sessionId'],
      title: json['title'],
      createdAt: json['createdAt'],
      lastActiveAt: json['lastActiveAt'],
    );
  }
}