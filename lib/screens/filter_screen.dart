import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ion/repositories/admin_repository.dart';
import 'package:ion/store.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _searchCtrl = TextEditingController();
  List<NoticeItem> _notices = [];
  bool _loading = true;
  bool _hasError = false;
  int _page = 0;
  int _totalPages = 1;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_rebuild);
    _load();
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_rebuild);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _load({int page = 0, String keyword = ''}) async {
    setState(() { _loading = true; _hasError = false; });
    try {
      final params = {
        'page': '$page',
        'size': '$_pageSize',
        if (keyword.isNotEmpty) 'keyword': keyword,
      };
      final uri = Uri.parse('${Store.baseUrl}/notices')
          .replace(queryParameters: params);
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
        if (mounted) setState(() { _loading = false; _hasError = true; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _hasError = true; });
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
            padding: const EdgeInsets.fromLTRB(27, 18, 18, 4),
            child: Text(
              '공지사항',
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
              child: Column(
                children: [
                  _searchBar(isLight),
                  Expanded(child: _body(isLight)),
                  if (!_loading && !_hasError && _totalPages > 1)
                    _pagination(isLight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(bool isLight) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          spacing: 10,
          children: [
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : const Color(0xFF4B4F5B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.search,
                        size: 18,
                        color: const Color(0xffA0A7BB)),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: (_) => _search(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isLight
                              ? const Color(0xFF1E1F22)
                              : const Color(0xFFEEEEEE),
                        ),
                        decoration: const InputDecoration(
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
                        child: const Icon(Icons.close,
                            size: 16, color: Color(0xffA0A7BB)),
                      ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _search,
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10A37F),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text('검색',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );

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
            onTap: () => _load(),
            child: const Text('다시 시도',
                style: TextStyle(
                    color: Color(0xFF10A37F),
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      );
    }
    if (_notices.isEmpty) {
      return Center(
        child: Text('공지사항이 없습니다.',
            style: TextStyle(
                color: isLight
                    ? const Color(0xFF9F9F9F)
                    : const Color(0xFFABABAB))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: _notices.length,
      separatorBuilder: (_, i) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _noticeCard(_notices[i], isLight),
    );
  }

  Widget _noticeCard(NoticeItem n, bool isLight) => GestureDetector(
        onTap: () => _openDetail(n),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF4B4F5B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(n.title,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isLight
                                ? const Color(0xFF1E1F22)
                                : const Color(0xFFEEEEEE))),
                    Row(
                      spacing: 8,
                      children: [
                        Text(n.authorName,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF))),
                        const Text('·',
                            style: TextStyle(color: Color(0xFF9CA3AF))),
                        Text(_fmtDate(n.publishedAt),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      );

  Widget _pagination(bool isLight) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
            Text('${_page + 1} / $_totalPages',
                style: TextStyle(
                    fontSize: 13,
                    color: isLight
                        ? const Color(0xFF6B7280)
                        : const Color(0xFFABABAB))),
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
  }) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF4B4F5B),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon,
              size: 18,
              color: enabled
                  ? (isLight
                      ? const Color(0xFF374151)
                      : const Color(0xFFEEEEEE))
                  : const Color(0xFFD1D5DB)),
        ),
      );
}

class _NoticeDetailDialog extends StatefulWidget {
  const _NoticeDetailDialog({
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
      setState(() { _content = widget.notice.content; _loading = false; });
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 560),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.notice.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [
                Text(widget.notice.authorName,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
                const Text('·',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
                Text(_fmtDate(widget.notice.publishedAt),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF10A37F), strokeWidth: 2),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _content ?? '내용을 불러올 수 없습니다.',
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: Color(0xFF374151)),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기',
                    style: TextStyle(color: Color(0xFF6B7280))),
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
