import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ion/models/history_chat_model.dart';
import 'package:ion/repositories/chat_repository.dart';
import 'package:ion/models/chat_session_model.dart';
import 'package:ion/store.dart';

class HistoryChatList extends StatefulWidget {
  const HistoryChatList({
    super.key,
    required this.selectedChatId,
    required this.changeChat,
  });

  final String selectedChatId;
  final Function(String) changeChat;

  @override
  State<HistoryChatList> createState() => _HistoryChatListState();
}

class _HistoryChatListState extends State<HistoryChatList> {
  final _chatRepository = ChatRepository();
  final List<HistoryChatModel> historyChats = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSessions());
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final sessions = await _chatRepository.getSessions();
      final mapped = sessions.map(_sessionToModel).toList();
      setState(() {
        historyChats
          ..clear()
          ..addAll(mapped);
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  HistoryChatModel _sessionToModel(ChatSession s) => HistoryChatModel(
        id: s.sessionId,
        isPinned: false,
        isSaved: false,
        lastMessageAt: DateTime.tryParse(s.lastActiveAt) ?? DateTime.now(),
        title: s.title,
        content: '',
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF10A37F),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_hasError) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                '목록을 불러오지 못했습니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: Store.isLightMode.value
                      ? const Color(0xFF9F9F9F)
                      : const Color(0xFFABABAB),
                ),
              ),
              GestureDetector(
                onTap: _loadSessions,
                child: Text(
                  '다시 시도',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF10A37F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (historyChats.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            '대화 기록이 없습니다.',
            style: TextStyle(
              fontSize: 13,
              color: Store.isLightMode.value
                  ? const Color(0xFF9F9F9F)
                  : const Color(0xFFABABAB),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ListView.separated(
          itemCount: historyChats.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) => chatItem(historyChats[index]),
        ),
      ),
    );
  }

  Widget chatItem(HistoryChatModel chat) {
    final isSelected = widget.selectedChatId == chat.id;

    Color selectedBackground = Store.isLightMode.value
        ? const Color(0xFFE3FEF7)
        : const Color(0xFF1E1F22);
    Color titleColor = Store.isLightMode.value
        ? const Color(0xFF1E1F22)
        : const Color(0xFFEEEEEE);
    Color dateColor = Store.isLightMode.value
        ? const Color(0xFF9F9F9F)
        : const Color(0x99ABABAB);

    return GestureDetector(
      onTap: () => widget.changeChat(chat.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? selectedBackground : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 15,
                height: 15,
                child: chat.isPinned
                    ? SvgPicture.asset('assets/icons/union.svg')
                    : null,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Text(
                          chat.title,
                          style: TextStyle(
                            fontSize: 15,
                            color: titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat.displayTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: dateColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
