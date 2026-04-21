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

  String get displayTime {
    final now = DateTime.now();

    final diff = now.difference(lastMessageAt);

    // 1시간 미만
    if(diff.inMinutes < 60) {
      return 'Now';
    }
    
    // 같은 날
    final isSameDay = now.year == lastMessageAt.year &&
        now.month == lastMessageAt.month &&
        now.day == lastMessageAt.day;
    
    if(isSameDay) {
      int hour = lastMessageAt.hour;
      final minute = lastMessageAt.minute.toString().padLeft(2, '0');
      final isAM = hour < 12;

      hour %= 12;
      if(hour == 0) hour = 12;

      return '$hour:$minute ${isAM ? 'AM' : 'PM'}';
    }

    // 7일 이내
    if(diff.inDays < 7) {
      final weekdays = ["월", "화", "수", "목", "금", "토", "일"];
      return weekdays[lastMessageAt.weekday - 1];
    }

    // 일주일 전
    return '${lastMessageAt.month}월 ${lastMessageAt.day}일';
  }
}
