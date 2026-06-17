import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ion/enums/history_tap.dart';
import 'package:ion/models/history_chat_model.dart';
import 'package:ion/repositories/chat_repository.dart';
import 'package:ion/models/chat_session_model.dart';
import 'package:ion/store.dart';
import 'package:ion/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryChatList extends StatefulWidget {
  HistoryChatList({
    super.key,
    required this.selectedChatId,
    required this.changeChat,
    required this.selectTap,
    this.onCountsChanged,
  });

  final String selectedChatId;
  final Function(String) changeChat;
  final HistoryTap selectTap;
  final void Function(int chats, int saved)? onCountsChanged;

  @override
  State<HistoryChatList> createState() => HistoryChatListState();
}

class HistoryChatListState extends State<HistoryChatList> {
  final _chatRepository = ChatRepository();
  final List<HistoryChatModel> _allChats = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _hoveredId;
  String? _popupOpenId; // 팝업이 열린 아이템 ID — 팝업 중 버튼이 트리에서 제거되는 것 방지

  List<HistoryChatModel> get _displayedChats =>
      widget.selectTap == HistoryTap.saved
      ? _allChats.where((c) => c.isSaved).toList()
      : _allChats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSessions());
    Store.chatListRefresh.addListener(_loadSessions);
  }

  @override
  void dispose() {
    Store.chatListRefresh.removeListener(_loadSessions);
    super.dispose();
  }

  Future<void> reload() => _loadSessions();

  @override
  void didUpdateWidget(HistoryChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectTap != widget.selectTap) setState(() {});
  }

  void _notifyCounts() {
    widget.onCountsChanged?.call(
      _allChats.length,
      _allChats.where((c) => c.isSaved).length,
    );
  }

  static final _savedKey = 'savedSessionIds';

  Future<List<String>> _getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedKey) ?? [];
  }

  Future<void> _setSavedIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedKey, ids);
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final results = await Future.wait([
        _chatRepository.getSessions(),
        _getSavedIds(),
      ]);
      final sessions = results[0] as List<ChatSession>;
      final savedIds = results[1] as List<String>;
      setState(() {
        _allChats
          ..clear()
          ..addAll(sessions.map((s) => _sessionToModel(s, savedIds)));
        _isLoading = false;
      });
      _notifyCounts();

      // 현재 보고 있는 채팅방의 제목이 바뀌었다면 헤더 제목도 갱신
      final selectedId = Store.selectedSessionId.value;
      if (selectedId.isNotEmpty) {
        final selected = _allChats.where((c) => c.id == selectedId);
        if (selected.isNotEmpty) {
          Store.selectedSessionTitle.value = selected.first.title;
        }
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  HistoryChatModel _sessionToModel(ChatSession s, List<String> savedIds) =>
      HistoryChatModel(
        id: s.sessionId,
        isSaved: savedIds.contains(s.sessionId),
        lastMessageAt: DateTime.tryParse(s.lastActiveAt) ?? DateTime.now(),
        title: s.title,
        content: '',
      );

  Future<void> _toggleSave(HistoryChatModel chat) async {
    final idx = _allChats.indexWhere((c) => c.id == chat.id);
    if (idx == -1) return;
    final newSaved = !chat.isSaved;
    setState(() => _allChats[idx] = chat.copyWith(isSaved: newSaved));
    final savedIds = await _getSavedIds();
    if (newSaved) {
      if (!savedIds.contains(chat.id)) savedIds.add(chat.id);
    } else {
      savedIds.remove(chat.id);
    }
    await _setSavedIds(savedIds);
    _notifyCounts();
  }

  Future<void> _deleteSession(HistoryChatModel chat) async {
    // 낙관적 삭제: 즉시 목록에서 제거
    final idx = _allChats.indexWhere((c) => c.id == chat.id);
    setState(() => _allChats.removeWhere((c) => c.id == chat.id));
    if (Store.selectedSessionId.value == chat.id) {
      Store.selectedSessionId.value = '';
      Store.selectedSessionTitle.value = '';
    }
    _notifyCounts();

    final ok = await _chatRepository.deleteSession(chat.id);
    if (!mounted) return;
    if (!ok) {
      // API 실패 시 복구
      if (idx != -1) setState(() => _allChats.insert(idx, chat));
      _notifyCounts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제에 실패했습니다. 다시 시도해주세요.')),
      );
      return;
    }

    // 저장 목록에서도 제거
    final savedIds = await _getSavedIds();
    if (savedIds.remove(chat.id)) await _setSavedIds(savedIds);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Expanded(
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
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: _loadSessions,
                child: Text(
                  '다시 시도',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF10A37F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_displayedChats.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            widget.selectTap == HistoryTap.saved
                ? '저장된 대화가 없습니다.'
                : '대화 기록이 없습니다.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: ListView.separated(
          itemCount: _displayedChats.length,
          separatorBuilder: (_, i) => SizedBox(height: 10),
          itemBuilder: (_, index) => _chatItem(_displayedChats[index]),
        ),
      ),
    );
  }

  Widget _chatItem(HistoryChatModel chat) {
    final isSelected = widget.selectedChatId == chat.id;
    final isHovered = _hoveredId == chat.id || _popupOpenId == chat.id;

    final selectedBg = AppColors.historyItemSelectedBackground;
    final titleColor = AppColors.textPrimary;
    final dateColor = AppColors.historyItemDateColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredId = chat.id),
      onExit: (_) => setState(() {
        if (_hoveredId == chat.id) _hoveredId = null;
      }),
      child: GestureDetector(
        onTap: () {
          Store.selectedSessionTitle.value = chat.title;
          widget.changeChat(chat.id);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? selectedBg : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  width: 15,
                  height: 15,
                  child: chat.isSaved
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
                      spacing: 6,
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
                        if (isHovered)
                          _moreButton(chat, titleColor)
                        else
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
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moreButton(HistoryChatModel chat, Color iconColor) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_horiz, size: 18, color: iconColor),
      iconSize: 18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: AppColors.dialogBackground,
      elevation: 4,
      onOpened: () => setState(() => _popupOpenId = chat.id),
      onCanceled: () => setState(() => _popupOpenId = null),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'save',
          height: 36,
          child: Text(
            chat.isSaved ? '저장 해제' : '저장',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 36,
          child: Text(
            '삭제',
            style: TextStyle(fontSize: 13, color: Color(0xFFE53935)),
          ),
        ),
      ],
      onSelected: (value) {
        setState(() => _popupOpenId = null);
        if (value == 'save') _toggleSave(chat);
        if (value == 'delete') _deleteSession(chat);
      },
    );
  }
}
