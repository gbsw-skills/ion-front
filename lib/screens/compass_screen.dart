import 'package:flutter/material.dart';
import 'package:ion/models/chat_session_model.dart';
import 'package:ion/repositories/chat_repository.dart';
import 'package:ion/store.dart';
import 'package:ion/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _SortOption { recent, title }

class CompassScreen extends StatefulWidget {
  CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  final _repo = ChatRepository();
  final _searchController = TextEditingController();
  List<ChatSession> _sessions = [];
  List<String> _savedIds = [];
  bool _loading = true;
  bool _hasError = false;
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.recent;
  bool _showSavedOnly = false;

  static final _savedKey = 'savedSessionIds';

  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_rebuild);
    _load();
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_rebuild);
    _searchController.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final results = await Future.wait([
        _repo.getSessions(size: 50),
        _getSavedIds(),
      ]);
      final sessions = results[0] as List<ChatSession>;
      final savedIds = results[1] as List<String>;
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _savedIds = savedIds;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<List<String>> _getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedKey) ?? [];
  }

  void _openSession(ChatSession session) {
    Store.selectedSessionId.value = session.sessionId;
    Store.selectedSessionTitle.value = session.title;
    Store.currentIndex.value = 0;
  }

  List<ChatSession> get _filteredSessions {
    final query = _searchQuery.trim().toLowerCase();
    final list = _sessions.where((s) {
      if (_showSavedOnly && !_savedIds.contains(s.sessionId)) return false;
      if (query.isNotEmpty && !s.title.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();

    if (_sortOption == _SortOption.title) {
      list.sort((a, b) => a.title.compareTo(b.title));
    } else {
      list.sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));
    }
    return list;
  }

  Map<String, List<ChatSession>> _groupByDate(List<ChatSession> sessions) {
    final today = <ChatSession>[];
    final yesterday = <ChatSession>[];
    final lastWeek = <ChatSession>[];
    final older = <ChatSession>[];

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    for (final s in sessions) {
      DateTime dt;
      try {
        dt = DateTime.parse(s.lastActiveAt).toLocal();
      } catch (_) {
        older.add(s);
        continue;
      }
      final date = DateTime(dt.year, dt.month, dt.day);
      final diffDays = todayDate.difference(date).inDays;
      if (diffDays <= 0) {
        today.add(s);
      } else if (diffDays == 1) {
        yesterday.add(s);
      } else if (diffDays <= 7) {
        lastWeek.add(s);
      } else {
        older.add(s);
      }
    }

    final result = <String, List<ChatSession>>{};
    if (today.isNotEmpty) result['오늘'] = today;
    if (yesterday.isNotEmpty) result['어제'] = yesterday;
    if (lastWeek.isNotEmpty) result['지난 7일'] = lastWeek;
    if (older.isNotEmpty) result['이전'] = older;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Store.isLightMode.value;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(27, 18, 18, 4),
            child: Text(
              '탐색',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.fromLTRB(27, 0, 18, 0),
            child: _filterBar(),
          ),
          SizedBox(height: 14),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 18, bottom: 18),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _body(isLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar() => Row(
    children: [
      Expanded(child: _searchField()),
      SizedBox(width: 12),
      _segmentedControl<_SortOption>(
        options: {'최근순': _SortOption.recent, '제목순': _SortOption.title},
        current: _sortOption,
        onSelect: (v) => setState(() => _sortOption = v),
      ),
      SizedBox(width: 12),
      _segmentedControl<bool>(
        options: {'전체': false, '저장됨': true},
        current: _showSavedOnly,
        onSelect: (v) => setState(() => _showSavedOnly = v),
      ),
    ],
  );

  Widget _searchField() => Container(
    height: 38,
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.searchBarBackground.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(Icons.search, size: 16, color: AppColors.textMuted),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: '제목으로 검색...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _segmentedControl<T>({
    required Map<String, T> options,
    required T current,
    required void Function(T) onSelect,
  }) => Container(
    height: 38,
    padding: EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.themeTogglePillBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: options.entries.map((e) {
        final selected = e.value == current;
        return GestureDetector(
          onTap: () => onSelect(e.value),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.themeTogglePillThumb
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              e.key,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _body(bool isLight) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFF10A37F),
          strokeWidth: 2,
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text('불러오기 실패', style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: _load,
              child: Text(
                '다시 시도',
                style: TextStyle(
                  color: Color(0xFF10A37F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return _emptyState('아직 대화 기록이 없습니다.', showStartButton: true);
    }

    final filtered = _filteredSessions;
    if (filtered.isEmpty) {
      return _emptyState('검색 결과가 없습니다.', showStartButton: false);
    }

    final groups = _groupByDate(filtered);
    final slivers = <Widget>[
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              Text(
                '최근 대화 ${filtered.length}개',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              Spacer(),
              GestureDetector(
                onTap: _load,
                child: Icon(
                  Icons.refresh,
                  size: 18,
                  color: Color(0xFF10A37F),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    groups.forEach((label, items) {
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _sessionCard(items[i], isLight),
              childCount: items.length,
            ),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 110,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),
      );
    });

    slivers.add(
      SliverPadding(padding: EdgeInsets.only(bottom: 20)),
    );

    return CustomScrollView(slivers: slivers);
  }

  Widget _emptyState(String message, {required bool showStartButton}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.divider),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          if (showStartButton)
            GestureDetector(
              onTap: () => Store.currentIndex.value = 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF10A37F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '새 대화 시작',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sessionCard(ChatSession session, bool isLight) {
    final isSelected = Store.selectedSessionId.value == session.sessionId;
    final isSaved = _savedIds.contains(session.sessionId);

    return GestureDetector(
      onTap: () => _openSession(session),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFF10A37F).withValues(alpha: 0.1)
              : AppColors.surfaceBackground,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Color(0xFF10A37F), width: 1.5)
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
                    color: Color(0xFF10A37F).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: Color(0xFF10A37F),
                  ),
                ),
                Spacer(),
                if (isSaved)
                  Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.bookmark,
                      size: 14,
                      color: Color(0xFF10A37F),
                    ),
                  ),
                Text(
                  _timeAgo(session.lastActiveAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              truncateTitle(session.title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
