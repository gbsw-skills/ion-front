import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ion/repositories/admin_repository.dart';
import 'package:ion/store.dart';
import 'package:ion/theme/app_colors.dart';

class FilterScreen extends StatefulWidget {
  FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

enum _Tab { notices, documents }

class _FilterScreenState extends State<FilterScreen> {
  final _adminRepo = AdminRepository();
  final _searchCtrl = TextEditingController();
  List<NoticeItem> _notices = [];
  bool _loading = true;
  bool _hasError = false;
  int _page = 0;
  int _totalPages = 1;
  static final _pageSize = 20;

  _Tab _tab = _Tab.notices;
  List<DocumentItem> _docs = [];
  bool _docsLoading = true;
  bool _docsHasError = false;

  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_rebuild);
    _load();
    _loadDocs();
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_rebuild);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _load({int page = 0, String keyword = ''}) async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final params = {
        'page': '$page',
        'size': '$_pageSize',
        if (keyword.isNotEmpty) 'keyword': keyword,
      };
      final uri = Uri.parse(
        '${Store.baseUrl}/notices',
      ).replace(queryParameters: params);
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${Store.token}'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        final content = data['content'] as List;
        if (mounted) {
          setState(() {
            _notices = content.map((e) => NoticeItem.fromJson(e)).toList();
            _page = data['page'] ?? 0;
            _totalPages = data['totalPages'] ?? 1;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loading = false;
            _hasError = true;
          });
        }
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

  Future<void> _loadDocs() async {
    setState(() {
      _docsLoading = true;
      _docsHasError = false;
    });
    try {
      final docs = await _adminRepo.getDocuments(size: 50);
      if (mounted) {
        setState(() {
          _docs = docs;
          _docsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _docsLoading = false;
          _docsHasError = true;
        });
      }
    }
  }

  Future<NoticeItem?> _fetchDetail(int id) async {
    final res = await http.get(
      Uri.parse('${Store.baseUrl}/notices/$id'),
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    if (res.statusCode == 200) {
      return NoticeItem.fromJson(jsonDecode(res.body)['data']);
    }
    return null;
  }

  void _search() => _load(keyword: _searchCtrl.text.trim());

  void _openDetail(NoticeItem notice) {
    showDialog(
      context: context,
      builder: (_) => _NoticeDetailDialog(
        notice: notice,
        fetchDetail: _fetchDetail,
      ),
    );
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
            child: Row(
              children: [
                Text(
                  '공지사항',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                _tabControl(),
              ],
            ),
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
              child: _tab == _Tab.notices
                  ? Column(
                      children: [
                        _searchBar(isLight),
                        Expanded(child: _body(isLight)),
                        if (!_loading && !_hasError && _totalPages > 1)
                          _pagination(isLight),
                      ],
                    )
                  : _docsBody(isLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabControl() => Container(
    height: 38,
    padding: EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.themeTogglePillBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: {'공지사항': _Tab.notices, '자료실': _Tab.documents}.entries.map((
        e,
      ) {
        final selected = e.value == _tab;
        return GestureDetector(
          onTap: () => setState(() => _tab = e.value),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14),
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
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _docsBody(bool isLight) {
    if (_docsLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2,
        ),
      );
    }
    if (_docsHasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text('불러오기 실패', style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: _loadDocs,
              child: Text(
                '다시 시도',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_docs.isEmpty) {
      return Center(
        child: Text(
          '등록된 자료가 없습니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: _docs.length,
      separatorBuilder: (_, i) => SizedBox(height: 8),
      itemBuilder: (_, i) => _docCard(_docs[i]),
    );
  }

  Widget _docCard(DocumentItem d) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.surfaceBackground,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.cardDivider),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.cardDivider,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            d.fileType.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.paginationText,
            ),
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                d.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _fmtDate(d.uploadedAt),
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _searchBar(bool isLight) => Padding(
    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      spacing: 10,
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.search, size: 18, color: Color(0xffA0A7BB)),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _search(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '제목으로 검색',
                      hintStyle: TextStyle(color: Color(0xffA0A7BB)),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      _load();
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xffA0A7BB),
                    ),
                  ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: _search,
          child: Container(
            height: 42,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFF10A37F),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '검색',
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
              onTap: () => _load(),
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
    if (_notices.isEmpty) {
      return Center(
        child: Text(
          '공지사항이 없습니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: _notices.length,
      separatorBuilder: (_, i) => SizedBox(height: 8),
      itemBuilder: (_, i) => _noticeCard(_notices[i], isLight),
    );
  }

  Widget _noticeCard(NoticeItem n, bool isLight) => GestureDetector(
    onTap: () => _openDetail(n),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  n.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Text(
                      n.authorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    Text('·', style: TextStyle(color: Color(0xFF9CA3AF))),
                    Text(
                      _fmtDate(n.publishedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
        ],
      ),
    ),
  );

  Widget _pagination(bool isLight) => Padding(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        _pageBtn(
          icon: Icons.chevron_left,
          enabled: _page > 0,
          onTap: () => _load(page: _page - 1, keyword: _searchCtrl.text.trim()),
          isLight: isLight,
        ),
        Text(
          '${_page + 1} / $_totalPages',
          style: TextStyle(fontSize: 13, color: AppColors.paginationText),
        ),
        _pageBtn(
          icon: Icons.chevron_right,
          enabled: _page < _totalPages - 1,
          onTap: () => _load(page: _page + 1, keyword: _searchCtrl.text.trim()),
          isLight: isLight,
        ),
      ],
    ),
  );

  Widget _pageBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required bool isLight,
  }) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 18,
        color: enabled ? AppColors.pageBtnIcon : Color(0xFFD1D5DB),
      ),
    ),
  );
}

class _NoticeDetailDialog extends StatefulWidget {
  _NoticeDetailDialog({
    required this.notice,
    required this.fetchDetail,
  });
  final NoticeItem notice;
  final Future<NoticeItem?> Function(int id) fetchDetail;

  @override
  State<_NoticeDetailDialog> createState() => _NoticeDetailDialogState();
}

class _NoticeDetailDialogState extends State<_NoticeDetailDialog> {
  String? _content;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.notice.content != null) {
      setState(() {
        _content = widget.notice.content;
        _loading = false;
      });
      return;
    }
    final detail = await widget.fetchDetail(widget.notice.id);
    if (mounted) {
      setState(() {
        _content = detail?.content;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: 560),
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.notice.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [
                Text(
                  widget.notice.authorName,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text('·', style: TextStyle(color: AppColors.textMuted)),
                Text(
                  _fmtDate(widget.notice.publishedAt),
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(height: 1, color: AppColors.cardDivider),
            SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _content ?? '내용을 불러올 수 없습니다.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '닫기',
                  style: TextStyle(color: AppColors.paginationText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso;
  }
}
