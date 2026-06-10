import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ion/repositories/admin_repository.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/login_screen.dart';
import 'package:ion/store.dart';
import 'package:ion/theme/app_colors.dart';

enum _AdminSection { notices, documents, logs, llm }

class AdminPage extends StatefulWidget {
  AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _repo = AdminRepository();
  _AdminSection _section = _AdminSection.notices;

  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_rebuild);
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
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
    height: 60,
    decoration: BoxDecoration(
      color: AppColors.surfaceBackground,
      border: Border(bottom: BorderSide(color: AppColors.cardDivider)),
    ),
    padding: EdgeInsets.symmetric(horizontal: 28),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.admin_panel_settings_outlined,
            size: 18,
            color: AppColors.accent,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'ION 관리자',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Spacer(),
        Text(
          Store.displayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.pageBtnIcon,
          ),
        ),
        SizedBox(width: 16),
        Container(width: 1, height: 18, color: AppColors.cardDivider),
        SizedBox(width: 16),
        TextButton(
          onPressed: _logout,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            '로그아웃',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.dangerText,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sideNav() => Container(
    width: 220,
    decoration: BoxDecoration(
      color: AppColors.surfaceBackground,
      border: Border(right: BorderSide(color: AppColors.cardDivider)),
    ),
    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 12),
          child: Text(
            '관리 메뉴',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
        _navItem('공지사항', Icons.campaign_outlined, _AdminSection.notices),
        SizedBox(height: 4),
        _navItem('문서', Icons.folder_outlined, _AdminSection.documents),
        SizedBox(height: 4),
        _navItem('LLM 엔드포인트', Icons.memory_outlined, _AdminSection.llm),
        SizedBox(height: 4),
        _navItem('감사 로그', Icons.history, _AdminSection.logs),
      ],
    ),
  );

  Widget _navItem(String label, IconData icon, _AdminSection section) {
    final selected = _section == section;
    return GestureDetector(
      onTap: () => setState(() => _section = section),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 120),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.historyItemSelectedBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.accent : AppColors.paginationText,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.accent : AppColors.pageBtnIcon,
              ),
            ),
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
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (_) => false,
    );
  }
}

// ── 공지사항 ────────────────────────────────────────────
class _NoticesSection extends StatefulWidget {
  _NoticesSection({required this.repo});
  final AdminRepository repo;

  @override
  State<_NoticesSection> createState() => _NoticesSectionState();
}

class _NoticesSectionState extends State<_NoticesSection> {
  List<NoticeItem> _notices = [];
  bool _loading = true;
  int? _detailLoadingId;

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
          ? _EmptyHint('등록된 공지사항이 없습니다.')
          : ListView.separated(
              padding: EdgeInsets.all(24),
              itemCount: _notices.length,
              separatorBuilder: (_, i) => SizedBox(height: 8),
              itemBuilder: (_, i) => _noticeCard(_notices[i]),
            ),
    );
  }

  Widget _noticeCard(NoticeItem n) => GestureDetector(
    onTap: () => _openDetail(n),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardDivider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  n.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${n.authorName}  ·  ${_fmtDate(n.publishedAt)}',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (_detailLoadingId == n.id)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            )
          else
            _IconBtn(
              Icons.edit_outlined,
              AppColors.paginationText,
              () => _showForm(context, notice: n),
            ),
          SizedBox(width: 4),
          _IconBtn(
            Icons.delete_outline,
            AppColors.deleteButton,
            () => _confirmDelete(context, n),
          ),
        ],
      ),
    ),
  );

  Future<void> _openDetail(NoticeItem n) async {
    setState(() => _detailLoadingId = n.id);
    final detail = await widget.repo.getNotice(n.id);
    if (!mounted) return;
    setState(() => _detailLoadingId = null);
    showDialog(
      context: context,
      builder: (_) => _NoticeDetailDialog(notice: detail ?? n),
    );
  }

  Future<void> _showForm(BuildContext ctx, {NoticeItem? notice}) async {
    var full = notice;
    if (notice != null) {
      setState(() => _detailLoadingId = notice.id);
      full = await widget.repo.getNotice(notice.id) ?? notice;
      if (!mounted) return;
      setState(() => _detailLoadingId = null);
    }
    if (!ctx.mounted) return;
    showDialog(
      context: ctx,
      builder: (_) => _NoticeFormDialog(
        repo: widget.repo,
        notice: full,
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
  _NoticeFormDialog({required this.repo, this.notice, required this.onSaved});
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
        publishedAt: now,
      );
    } else {
      ok = await widget.repo.updateNotice(
        id: widget.notice!.id,
        title: _title.text.trim(),
        content: _content.text.trim(),
        publishedAt: now,
      );
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
        SizedBox(height: 16),
        _FormField(label: '내용', controller: _content, maxLines: 6),
      ],
    );
  }
}

class _NoticeDetailDialog extends StatelessWidget {
  _NoticeDetailDialog({required this.notice});
  final NoticeItem notice;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 560,
        constraints: BoxConstraints(maxHeight: 520),
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${notice.authorName}  ·  ${_fmtDate(notice.publishedAt)}',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            SizedBox(height: 20),
            Divider(height: 1, color: AppColors.cardDivider),
            SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  notice.content?.isNotEmpty == true
                      ? notice.content!
                      : '내용이 없습니다.',
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

// ── 문서 ────────────────────────────────────────────────
class _DocumentsSection extends StatefulWidget {
  _DocumentsSection({required this.repo});
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
          ? _EmptyHint('등록된 문서가 없습니다.')
          : ListView.separated(
              padding: EdgeInsets.all(24),
              itemCount: _docs.length,
              separatorBuilder: (_, i) => SizedBox(height: 8),
              itemBuilder: (_, i) => _docCard(_docs[i]),
            ),
    );
  }

  Widget _docCard(DocumentItem d) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.surfaceBackground,
      borderRadius: BorderRadius.circular(12),
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
        _IconBtn(
          Icons.delete_outline,
          AppColors.deleteButton,
          () => _confirmDelete(context, d),
        ),
      ],
    ),
  );

  void _showUpload(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => _UploadDialog(repo: widget.repo, onUploaded: _load),
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
  _UploadDialog({required this.repo, required this.onUploaded});
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
        SizedBox(height: 16),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: _fileName != null
                    ? AppColors.accent
                    : AppColors.borderMuted,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _fileName ?? 'PDF / DOCX 파일 선택',
              style: TextStyle(
                fontSize: 14,
                color: _fileName != null
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          '최대 50MB · PDF, DOCX',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ── LLM 엔드포인트 ───────────────────────────────────────
class _LlmSection extends StatefulWidget {
  _LlmSection({required this.repo});
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
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final result = await widget.repo.getLlmEndpoints();
      if (mounted)
        setState(() {
          _endpoints = result;
          _loading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _hasError = true;
        });
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.deleteButton : AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _SectionScaffold(
        title: 'LLM 엔드포인트',
        loading: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text('불러오기 실패', style: TextStyle(color: AppColors.textMuted)),
              GestureDetector(
                onTap: _load,
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
          ? _EmptyHint('등록된 LLM 엔드포인트가 없습니다.')
          : ListView.separated(
              padding: EdgeInsets.all(24),
              itemCount: _endpoints.length,
              separatorBuilder: (_, i) => SizedBox(height: 12),
              itemBuilder: (_, i) => _endpointCard(_endpoints[i]),
            ),
    );
  }

  Widget _endpointCard(LlmEndpoint ep) => Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surfaceBackground,
      borderRadius: BorderRadius.circular(12),
      border: ep.isDefault
          ? Border.all(color: AppColors.accent, width: 1.5)
          : Border.all(color: AppColors.cardDivider),
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
                  Text(
                    ep.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (ep.isDefault) _badge('기본', AppColors.accent),
                  _badge(
                    ep.enabled ? '활성' : '비활성',
                    ep.enabled ? AppColors.infoBadge : AppColors.textMuted,
                  ),
                ],
              ),
            ),
            // 활성화 토글
            Tooltip(
              message: ep.enabled ? '비활성화' : '활성화',
              child: _IconBtn(
                ep.enabled ? Icons.toggle_on : Icons.toggle_off,
                ep.enabled ? AppColors.infoBadge : AppColors.borderMuted,
                () => _toggleEnabled(ep),
              ),
            ),
            // 기본값 설정
            Tooltip(
              message: ep.isDefault ? '기본 엔드포인트' : '기본값으로 설정',
              child: _IconBtn(
                ep.isDefault ? Icons.star : Icons.star_outline,
                ep.isDefault ? AppColors.warningBadge : AppColors.borderMuted,
                ep.isDefault ? () {} : () => _setDefault(ep),
              ),
            ),
            _IconBtn(
              Icons.edit_outlined,
              AppColors.paginationText,
              () => _showForm(context, endpoint: ep),
            ),
            _IconBtn(
              Icons.delete_outline,
              AppColors.deleteButton,
              () => _confirmDelete(context, ep),
            ),
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
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    ),
  );

  Widget _infoRow(String label, String value, {int maxLines = 1}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 110,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: AppColors.pageBtnIcon),
        ),
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
  _LlmFormDialog({
    required this.repo,
    this.endpoint,
    required this.onSaved,
    this.onError,
  });
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
      text: (ep?.temperature ?? 0.7).toString(),
    );
    _maxTokens = TextEditingController(
      text: (ep?.maxTokens ?? 1024).toString(),
    );
    _enabled = ep?.enabled ?? true;
    _isDefault = ep?.isDefault ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _baseUrl,
      _apiKey,
      _model,
      _systemPrompt,
      _temperature,
      _maxTokens,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty ||
        _baseUrl.text.trim().isEmpty ||
        _model.text.trim().isEmpty) {
      return;
    }
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
      backgroundColor: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 540,
        padding: EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.endpoint == null ? '새 엔드포인트 등록' : '엔드포인트 수정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 24),
              _FormField(label: '이름 *', controller: _name),
              SizedBox(height: 14),
              _FormField(label: 'Base URL *', controller: _baseUrl),
              SizedBox(height: 14),
              _FormField(label: 'API Key', controller: _apiKey),
              SizedBox(height: 14),
              _FormField(label: '모델 *', controller: _model),
              SizedBox(height: 14),
              _FormField(
                label: 'System Prompt',
                controller: _systemPrompt,
                maxLines: 4,
              ),
              SizedBox(height: 14),
              Row(
                spacing: 14,
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Temperature',
                      controller: _temperature,
                    ),
                  ),
                  Expanded(
                    child: _FormField(
                      label: 'Max Tokens',
                      controller: _maxTokens,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '취소',
                      style: TextStyle(color: AppColors.paginationText),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('저장'),
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
  _Toggle({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 8,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.pageBtnIcon,
        ),
      ),
      Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.accent,
        activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
      ),
    ],
  );
}

// ── 감사 로그 ────────────────────────────────────────────
class _LogsSection extends StatefulWidget {
  _LogsSection({required this.repo});
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
          ? _EmptyHint('로그가 없습니다.')
          : ListView.separated(
              padding: EdgeInsets.all(24),
              itemCount: _logs.length,
              separatorBuilder: (_, i) => SizedBox(height: 8),
              itemBuilder: (_, i) => _logCard(_logs[i]),
            ),
    );
  }

  Widget _logCard(LogItem l) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cardDivider),
    ),
    child: Row(
      spacing: 16,
      children: [
        Text(
          _fmtDate(l.createdAt),
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        Expanded(
          child: Text(
            '${l.adminName}  ·  ${l.action}',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
        Text(
          '${l.targetType} #${l.targetId}',
          style: TextStyle(fontSize: 12, color: AppColors.paginationText),
        ),
      ],
    ),
  );
}

// ── 공통 UI 컴포넌트 ─────────────────────────────────────
class _SectionScaffold extends StatelessWidget {
  _SectionScaffold({
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
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            border: Border(bottom: BorderSide(color: AppColors.cardDivider)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              ?action,
            ],
          ),
        ),
        Expanded(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                )
              : child,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  _ActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _IconBtn extends StatelessWidget {
  _IconBtn(this.icon, this.color, this.onTap);
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, size: 18, color: color),
    onPressed: onTap,
    padding: EdgeInsets.zero,
    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
  );
}

class _EmptyHint extends StatelessWidget {
  _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(text, style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
  );
}

class _FormDialog extends StatelessWidget {
  _FormDialog({
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
      backgroundColor: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 480,
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24),
            ...children,
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 10,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '취소',
                    style: TextStyle(color: AppColors.paginationText),
                  ),
                ),
                ElevatedButton(
                  onPressed: saving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: saving
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('저장'),
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
  _FormField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.pageBtnIcon,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderMuted),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  _ConfirmDialog({required this.message, required this.onConfirm});
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        '삭제 확인',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: TextStyle(color: AppColors.paginationText)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deleteButton,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('삭제'),
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
