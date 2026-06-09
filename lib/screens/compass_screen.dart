import 'package:flutter/material.dart';
import 'package:ion/models/chat_session_model.dart';
import 'package:ion/repositories/chat_repository.dart';
import 'package:ion/store.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  final _repo = ChatRepository();
  List<ChatSession> _sessions = [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_rebuild);
    _load();
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _load() async {
    setState(() { _loading = true; _hasError = false; });
    try {
      final sessions = await _repo.getSessions(size: 50);
      if (mounted) setState(() { _sessions = sessions; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _hasError = true; });
    }
  }

  void _openSession(ChatSession session) {
    Store.selectedSessionId.value = session.sessionId;
    Store.selectedSessionTitle.value = session.title;
    Store.currentIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Store.isLightMode.value;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(27, 18, 18, 4),
            child: Text(
              '탐색',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isLight
                    ? const Color(0xFF1E1F22)
                    : const Color(0xFFEEEEEE),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 18, bottom: 18),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: isLight
                    ? const Color(0xffF5F5F5)
                    : const Color(0xFF3F424A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _body(isLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(bool isLight) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF10A37F), strokeWidth: 2),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
          Text('불러오기 실패',
              style: TextStyle(
                  color: isLight
                      ? const Color(0xFF9F9F9F)
                      : const Color(0xFFABABAB))),
          GestureDetector(
            onTap: _load,
            child: const Text('다시 시도',
                style: TextStyle(
                    color: Color(0xFF10A37F),
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, spacing: 16, children: [
          Icon(Icons.chat_bubble_outline,
              size: 48,
              color: isLight
                  ? const Color(0xFFD0D0D0)
                  : const Color(0xFF4A4F5E)),
          Text('아직 대화 기록이 없습니다.',
              style: TextStyle(
                  fontSize: 15,
                  color: isLight
                      ? const Color(0xFF9F9F9F)
                      : const Color(0xFFABABAB))),
          GestureDetector(
            onTap: () => Store.currentIndex.value = 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF10A37F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('새 대화 시작',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text('최근 대화 ${_sessions.length}개',
                    style: TextStyle(
                        fontSize: 13,
                        color: isLight
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFFABABAB))),
                const Spacer(),
                GestureDetector(
                  onTap: _load,
                  child: const Icon(Icons.refresh,
                      size: 18, color: Color(0xFF10A37F)),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _sessionCard(_sessions[i], isLight),
              childCount: _sessions.length,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 110,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sessionCard(ChatSession session, bool isLight) {
    final isSelected =
        Store.selectedSessionId.value == session.sessionId;

    return GestureDetector(
      onTap: () => _openSession(session),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10A37F).withValues(alpha: 0.1)
              : isLight
                  ? Colors.white
                  : const Color(0xFF4B4F5B),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF10A37F), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10A37F).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      size: 14, color: Color(0xFF10A37F)),
                ),
                const Spacer(),
                Text(
                  _timeAgo(session.lastActiveAt),
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
            const Spacer(),
            Text(
              session.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isLight
                    ? const Color(0xFF1E1F22)
                    : const Color(0xFFEEEEEE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _timeAgo(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '방금 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}/${dt.day}';
  } catch (_) {
    return '';
  }
}
