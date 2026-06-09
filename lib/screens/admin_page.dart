import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ion/repositories/admin_repository.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/login_screen.dart';
import 'package:ion/store.dart';

enum _AdminSection { notices, documents, logs, llm }

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _repo = AdminRepository();
  _AdminSection _section = _AdminSection.notices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: Row(
              children: [
                _sideNav(),
                Expanded(child: _content()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() => Container(
        height: 56,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          children: [
            const Text('ION 관리자',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1F22))),
            const Spacer(),
            Text(Store.displayName,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            const SizedBox(width: 16),
            TextButton(
              onPressed: _logout,
              child: const Text('로그아웃',
                  style: TextStyle(fontSize: 13, color: Color(0xFFE53935))),
            ),
          ],
        ),
      );

  Widget _sideNav() => Container(
        width: 200,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          children: [
            _navItem('공지사항', Icons.campaign_outlined, _AdminSection.notices),
            _navItem('문서', Icons.folder_outlined, _AdminSection.documents),
            _navItem('LLM 엔드포인트', Icons.memory_outlined, _AdminSection.llm),
            _navItem('감사 로그', Icons.history, _AdminSection.logs),
          ],
        ),
      );

  Widget _navItem(String label, IconData icon, _AdminSection section) {
    final selected = _section == section;
    return GestureDetector(
      onTap: () => setState(() => _section = section),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8FAF5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(icon,
                size: 18,
                color: selected
                    ? const Color(0xFF10A37F)
                    : const Color(0xFF6B7280)),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? const Color(0xFF10A37F)
                        : const Color(0xFF374151))),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    switch (_section) {
      case _AdminSection.notices:
        return _NoticesSection(repo: _repo);
      case _AdminSection.documents:
        return _DocumentsSection(repo: _repo);
      case _AdminSection.llm:
        return _LlmSection(repo: _repo);
      case _AdminSection.logs:
        return _LogsSection(repo: _repo);
    }
  }

  Future<void> _logout() async {
    await AuthRepository().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

// ── 공지사항 ────────────────────────────────────────────
class _NoticesSection extends StatefulWidget {
  const _NoticesSection({required this.repo});
  final AdminRepository repo;

  @override
  State<_NoticesSection> createState() => _NoticesSectionState();
}

class _NoticesSectionState extends State<_NoticesSection> {
  List<NoticeItem> _notices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _notices = await widget.repo.getNotices();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: '공지사항 관리',
      action: _ActionButton(
        label: '새 공지 작성',
        onTap: () => _showForm(context),
      ),
      loading: _loading,
      child: _notices.isEmpty
          ? const _EmptyHint('등록된 공지사항이 없습니다.')
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _notices.length,
              separatorBuilder: (_, i) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _noticeCard(_notices[i]),
            ),
    );
  }

  Widget _noticeCard(NoticeItem n) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(n.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('${n.authorName}  ·  ${_fmtDate(n.publishedAt)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            _IconBtn(Icons.edit_outlined, const Color(0xFF6B7280),
                () => _showForm(context, notice: n)),
            const SizedBox(width: 4),
            _IconBtn(Icons.delete_outline, const Color(0xFFEF4444),
                () => _confirmDelete(context, n)),
          ],
        ),
      );

  void _showForm(BuildContext ctx, {NoticeItem? notice}) {
    showDialog(
      context: ctx,
      builder: (_) => _NoticeFormDialog(
        repo: widget.repo,
        notice: notice,
        onSaved: _load,
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, NoticeItem n) {
    showDialog(
      context: ctx,
      builder: (_) => _ConfirmDialog(
        message: '"${n.title}" 공지사항을 삭제할까요?',
        onConfirm: () async {
          await widget.repo.deleteNotice(n.id);
          _load();
        },
      ),
    );
  }
}

class _NoticeFormDialog extends StatefulWidget {
  const _NoticeFormDialog(
      {required this.repo, this.notice, required this.onSaved});
  final AdminRepository repo;
  final NoticeItem? notice;
  final VoidCallback onSaved;

  @override
  State<_NoticeFormDialog> createState() => _NoticeFormDialogState();
}

class _NoticeFormDialogState extends State<_NoticeFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.notice?.title ?? '');
    _content = TextEditingController(text: widget.notice?.content ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final now = DateTime.now().toUtc().toIso8601String();
    bool ok;
    if (widget.notice == null) {
      ok = await widget.repo.createNotice(
          title: _title.text.trim(),
          content: _content.text.trim(),
          publishedAt: now);
    } else {
      ok = await widget.repo.updateNotice(
          id: widget.notice!.id,
          title: _title.text.trim(),
          content: _content.text.trim(),
          publishedAt: now);
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      widget.onSaved();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialog(
      title: widget.notice == null ? '새 공지 작성' : '공지 수정',
      saving: _saving,
      onSave: _save,
      children: [
        _FormField(label: '제목', controller: _title),
        const SizedBox(height: 16),
        _FormField(label: '내용', controller: _content, maxLines: 6),
      ],
    );
  }
}

// ── 문서 ────────────────────────────────────────────────
class _DocumentsSection extends StatefulWidget {
  const _DocumentsSection({required this.repo});
  final AdminRepository repo;

  @override
  State<_DocumentsSection> createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends State<_DocumentsSection> {
  List<DocumentItem> _docs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _docs = await widget.repo.getDocuments();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: '문서 관리',
      action: _ActionButton(
        label: '문서 업로드',
        onTap: () => _showUpload(context),
      ),
      loading: _loading,
      child: _docs.isEmpty
          ? const _EmptyHint('등록된 문서가 없습니다.')
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _docs.length,
              separatorBuilder: (_, i) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _docCard(_docs[i]),
            ),
    );
  }

  Widget _docCard(DocumentItem d) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(d.fileType.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(d.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(_fmtDate(d.uploadedAt),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            _IconBtn(Icons.delete_outline, const Color(0xFFEF4444),
                () => _confirmDelete(context, d)),
          ],
        ),
      );

  void _showUpload(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) =>
          _UploadDialog(repo: widget.repo, onUploaded: _load),
    );
  }

  void _confirmDelete(BuildContext ctx, DocumentItem d) {
    showDialog(
      context: ctx,
      builder: (_) => _ConfirmDialog(
        message: '"${d.title}" 문서를 삭제할까요?',
        onConfirm: () async {
          await widget.repo.deleteDocument(d.id);
          _load();
        },
      ),
    );
  }
}

class _UploadDialog extends StatefulWidget {
  const _UploadDialog({required this.repo, required this.onUploaded});
  final AdminRepository repo;
  final VoidCallback onUploaded;

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  final _titleCtrl = TextEditingController();
  String? _fileName;
  List<int>? _fileBytes;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    setState(() {
      _fileName = file.name;
      _fileBytes = file.bytes!.toList();
    });
  }

  Future<void> _upload() async {
    if (_titleCtrl.text.trim().isEmpty || _fileBytes == null) return;
    setState(() => _saving = true);
    final ok = await widget.repo.uploadDocument(
      title: _titleCtrl.text.trim(),
      fileBytes: _fileBytes!,
      fileName: _fileName!,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      widget.onUploaded();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialog(
      title: '문서 업로드',
      saving: _saving,
      onSave: _upload,
      children: [
        _FormField(label: '문서 제목', controller: _titleCtrl),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                  color: _fileName != null
                      ? const Color(0xFF10A37F)
                      : const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _fileName ?? 'PDF / DOCX 파일 선택',
              style: TextStyle(
                  fontSize: 14,
                  color: _fileName != null
                      ? const Color(0xFF1E1F22)
                      : const Color(0xFF9CA3AF)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text('최대 50MB · PDF, DOCX',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

// ── LLM 엔드포인트 ───────────────────────────────────────
class _LlmSection extends StatefulWidget {
  const _LlmSection({required this.repo});
  final AdminRepository repo;

  @override
  State<_LlmSection> createState() => _LlmSectionState();
}

class _LlmSectionState extends State<_LlmSection> {
  List<LlmEndpoint> _endpoints = [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _hasError = false; });
    try {
      final result = await widget.repo.getLlmEndpoints();
      if (mounted) setState(() { _endpoints = result; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _hasError = true; });
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? const Color(0xFFEF4444) : const Color(0xFF10A37F),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _SectionScaffold(
        title: 'LLM 엔드포인트',
        loading: false,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
            const Text('불러오기 실패', style: TextStyle(color: Color(0xFF9CA3AF))),
            GestureDetector(
              onTap: _load,
              child: const Text('다시 시도',
                  style: TextStyle(color: Color(0xFF10A37F), fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );
    }

    return _SectionScaffold(
      title: 'LLM 엔드포인트',
      action: _ActionButton(
        label: '새 엔드포인트 등록',
        onTap: () => _showForm(context),
      ),
      loading: _loading,
      child: _endpoints.isEmpty
          ? const _EmptyHint('등록된 LLM 엔드포인트가 없습니다.')
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _endpoints.length,
              separatorBuilder: (_, i) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _endpointCard(_endpoints[i]),
            ),
    );
  }

  Widget _endpointCard(LlmEndpoint ep) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: ep.isDefault
              ? Border.all(color: const Color(0xFF10A37F), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      Text(ep.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      if (ep.isDefault) _badge('기본', const Color(0xFF10A37F)),
                      _badge(
                          ep.enabled ? '활성' : '비활성',
                          ep.enabled
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
                // 활성화 토글
                Tooltip(
                  message: ep.enabled ? '비활성화' : '활성화',
                  child: _IconBtn(
                    ep.enabled ? Icons.toggle_on : Icons.toggle_off,
                    ep.enabled ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
                    () => _toggleEnabled(ep),
                  ),
                ),
                // 기본값 설정
                Tooltip(
                  message: ep.isDefault ? '기본 엔드포인트' : '기본값으로 설정',
                  child: _IconBtn(
                    ep.isDefault ? Icons.star : Icons.star_outline,
                    ep.isDefault
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFD1D5DB),
                    ep.isDefault ? () {} : () => _setDefault(ep),
                  ),
                ),
                _IconBtn(Icons.edit_outlined, const Color(0xFF6B7280),
                    () => _showForm(context, endpoint: ep)),
                _IconBtn(Icons.delete_outline, const Color(0xFFEF4444),
                    () => _confirmDelete(context, ep)),
              ],
            ),
            _infoRow('모델', ep.model),
            _infoRow('Base URL', ep.baseUrl),
            _infoRow('Temperature', ep.temperature.toString()),
            _infoRow('Max Tokens', ep.maxTokens.toString()),
            if (ep.systemPrompt.isNotEmpty)
              _infoRow('System Prompt', ep.systemPrompt, maxLines: 2),
          ],
        ),
      );

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );

  Widget _infoRow(String label, String value, {int maxLines = 1}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
          ),
        ],
      );

  void _showForm(BuildContext ctx, {LlmEndpoint? endpoint}) {
    showDialog(
      context: ctx,
      builder: (_) => _LlmFormDialog(
        repo: widget.repo,
        endpoint: endpoint,
        onSaved: _load,
        onError: () => _snack('저장에 실패했습니다.', error: true),
      ),
    );
  }

  Future<void> _toggleEnabled(LlmEndpoint ep) async {
    final body = {
      'name': ep.name,
      'baseUrl': ep.baseUrl,
      'apiKey': ep.apiKey,
      'model': ep.model,
      'systemPrompt': ep.systemPrompt,
      'temperature': ep.temperature,
      'maxTokens': ep.maxTokens,
      'enabled': !ep.enabled,
      'isDefault': ep.isDefault,
    };
    final ok = await widget.repo.updateLlmEndpoint(ep.id, body);
    if (!mounted) return;
    if (ok) {
      _load();
    } else {
      _snack('상태 변경에 실패했습니다.', error: true);
    }
  }

  Future<void> _setDefault(LlmEndpoint ep) async {
    final ok = await widget.repo.setDefaultLlmEndpoint(ep.id);
    if (!mounted) return;
    if (ok) {
      _load();
    } else {
      _snack('기본값 설정에 실패했습니다.', error: true);
    }
  }

  void _confirmDelete(BuildContext ctx, LlmEndpoint ep) {
    showDialog(
      context: ctx,
      builder: (_) => _ConfirmDialog(
        message: '"${ep.name}" 엔드포인트를 삭제할까요?',
        onConfirm: () async {
          final ok = await widget.repo.deleteLlmEndpoint(ep.id);
          if (!mounted) return;
          if (ok) {
            _load();
          } else {
            _snack('삭제에 실패했습니다.', error: true);
          }
        },
      ),
    );
  }
}

class _LlmFormDialog extends StatefulWidget {
  const _LlmFormDialog(
      {required this.repo, this.endpoint, required this.onSaved, this.onError});
  final AdminRepository repo;
  final LlmEndpoint? endpoint;
  final VoidCallback onSaved;
  final VoidCallback? onError;

  @override
  State<_LlmFormDialog> createState() => _LlmFormDialogState();
}

class _LlmFormDialogState extends State<_LlmFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _baseUrl;
  late final TextEditingController _apiKey;
  late final TextEditingController _model;
  late final TextEditingController _systemPrompt;
  late final TextEditingController _temperature;
  late final TextEditingController _maxTokens;
  late bool _enabled;
  late bool _isDefault;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final ep = widget.endpoint;
    _name = TextEditingController(text: ep?.name ?? '');
    _baseUrl = TextEditingController(text: ep?.baseUrl ?? '');
    _apiKey = TextEditingController(text: ep?.apiKey ?? '');
    _model = TextEditingController(text: ep?.model ?? '');
    _systemPrompt = TextEditingController(text: ep?.systemPrompt ?? '');
    _temperature = TextEditingController(
        text: (ep?.temperature ?? 0.7).toString());
    _maxTokens =
        TextEditingController(text: (ep?.maxTokens ?? 1024).toString());
    _enabled = ep?.enabled ?? true;
    _isDefault = ep?.isDefault ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _baseUrl, _apiKey, _model, _systemPrompt, _temperature, _maxTokens]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty ||
        _baseUrl.text.trim().isEmpty ||
        _model.text.trim().isEmpty) { return; }
    setState(() => _saving = true);

    final body = {
      'name': _name.text.trim(),
      'baseUrl': _baseUrl.text.trim(),
      'apiKey': _apiKey.text.trim(),
      'model': _model.text.trim(),
      'systemPrompt': _systemPrompt.text.trim(),
      'temperature': double.tryParse(_temperature.text) ?? 0.7,
      'maxTokens': int.tryParse(_maxTokens.text) ?? 1024,
      'enabled': _enabled,
      'isDefault': _isDefault,
    };

    bool ok;
    if (widget.endpoint == null) {
      ok = await widget.repo.createLlmEndpoint(body);
    } else {
      ok = await widget.repo.updateLlmEndpoint(widget.endpoint!.id, body);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      widget.onSaved();
    } else {
      setState(() => _saving = false);
      widget.onError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.endpoint == null ? '새 엔드포인트 등록' : '엔드포인트 수정',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _FormField(label: '이름 *', controller: _name),
              const SizedBox(height: 14),
              _FormField(label: 'Base URL *', controller: _baseUrl),
              const SizedBox(height: 14),
              _FormField(label: 'API Key', controller: _apiKey),
              const SizedBox(height: 14),
              _FormField(label: '모델 *', controller: _model),
              const SizedBox(height: 14),
              _FormField(
                  label: 'System Prompt',
                  controller: _systemPrompt,
                  maxLines: 4),
              const SizedBox(height: 14),
              Row(
                spacing: 14,
                children: [
                  Expanded(
                      child: _FormField(
                          label: 'Temperature', controller: _temperature)),
                  Expanded(
                      child: _FormField(
                          label: 'Max Tokens', controller: _maxTokens)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 24,
                children: [
                  _Toggle(
                    label: '활성화',
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                  _Toggle(
                    label: '기본 엔드포인트',
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소',
                        style: TextStyle(color: Color(0xFF6B7280))),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10A37F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        spacing: 8,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF10A37F),
            activeTrackColor: const Color(0xFF10A37F).withValues(alpha: 0.4),
          ),
        ],
      );
}

// ── 감사 로그 ────────────────────────────────────────────
class _LogsSection extends StatefulWidget {
  const _LogsSection({required this.repo});
  final AdminRepository repo;

  @override
  State<_LogsSection> createState() => _LogsSectionState();
}

class _LogsSectionState extends State<_LogsSection> {
  List<LogItem> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _logs = await widget.repo.getLogs();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: '감사 로그',
      loading: _loading,
      child: _logs.isEmpty
          ? const _EmptyHint('로그가 없습니다.')
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _logs.length,
              separatorBuilder: (_, i) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _logCard(_logs[i]),
            ),
    );
  }

  Widget _logCard(LogItem l) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          spacing: 16,
          children: [
            Text(_fmtDate(l.createdAt),
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF))),
            Expanded(
              child: Text('${l.adminName}  ·  ${l.action}',
                  style: const TextStyle(fontSize: 14)),
            ),
            Text('${l.targetType} #${l.targetId}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      );
}

// ── 공통 UI 컴포넌트 ─────────────────────────────────────
class _SectionScaffold extends StatelessWidget {
  const _SectionScaffold({
    required this.title,
    required this.child,
    required this.loading,
    this.action,
  });

  final String title;
  final Widget child;
  final bool loading;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              ?action,
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF10A37F), strokeWidth: 2))
              : child,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: const Color(0xFF10A37F),
              borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      );
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(this.icon, this.color, this.onTap);
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, size: 18, color: color),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
      );
}

class _FormDialog extends StatelessWidget {
  const _FormDialog({
    required this.title,
    required this.children,
    required this.saving,
    required this.onSave,
  });

  final String title;
  final List<Widget> children;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...children,
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 10,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  onPressed: saving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10A37F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField(
      {required this.label,
      required this.controller,
      this.maxLines = 1});

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF10A37F), width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.message, required this.onConfirm});
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('삭제 확인',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Text(message, style: const TextStyle(fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소',
              style: TextStyle(color: Color(0xFF6B7280))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('삭제'),
        ),
      ],
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
