import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ion/store.dart';

// ── 모델 ──────────────────────────────────────────────
class NoticeItem {
  final int id;
  final String title;
  final String authorName;
  final String publishedAt;
  String? content;

  NoticeItem({
    required this.id,
    required this.title,
    required this.authorName,
    required this.publishedAt,
    this.content,
  });

  factory NoticeItem.fromJson(Map<String, dynamic> j) => NoticeItem(
        id: j['id'],
        title: j['title'],
        authorName: j['authorName'] ?? '',
        publishedAt: j['publishedAt'] ?? '',
        content: j['content'],
      );
}

class DocumentItem {
  final int id;
  final String title;
  final String fileType;
  final String uploadedAt;

  DocumentItem({
    required this.id,
    required this.title,
    required this.fileType,
    required this.uploadedAt,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> j) => DocumentItem(
        id: j['id'],
        title: j['title'],
        fileType: j['fileType'] ?? '',
        uploadedAt: j['uploadedAt'] ?? '',
      );
}

class LogItem {
  final int id;
  final String adminName;
  final String action;
  final String targetType;
  final int targetId;
  final String createdAt;

  LogItem({
    required this.id,
    required this.adminName,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
  });

  factory LogItem.fromJson(Map<String, dynamic> j) => LogItem(
        id: j['id'],
        adminName: j['adminName'] ?? '',
        action: j['action'] ?? '',
        targetType: j['targetType'] ?? '',
        targetId: j['targetId'] ?? 0,
        createdAt: j['createdAt'] ?? '',
      );
}

class LlmEndpoint {
  final int id;
  final String name;
  final String baseUrl;
  final String apiKey;
  final String model;
  final String systemPrompt;
  final double temperature;
  final int maxTokens;
  final bool enabled;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;

  LlmEndpoint({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    required this.systemPrompt,
    required this.temperature,
    required this.maxTokens,
    required this.enabled,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LlmEndpoint.fromJson(Map<String, dynamic> j) => LlmEndpoint(
        id: j['id'],
        name: j['name'] ?? '',
        baseUrl: j['baseUrl'] ?? '',
        apiKey: j['apiKey'] ?? '',
        model: j['model'] ?? '',
        systemPrompt: j['systemPrompt'] ?? '',
        temperature: (j['temperature'] as num?)?.toDouble() ?? 0.7,
        maxTokens: j['maxTokens'] ?? 1024,
        enabled: j['enabled'] ?? true,
        isDefault: j['isDefault'] ?? false,
        createdAt: j['createdAt'] ?? '',
        updatedAt: j['updatedAt'] ?? '',
      );
}

// ── Repository ────────────────────────────────────────
class AdminRepository {
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Store.token}',
      };

  // ── 공지사항 ────────────────────────────────────────
  Future<List<NoticeItem>> getNotices({int page = 0, int size = 20}) async {
    final uri = Uri.parse('${Store.baseUrl}/notices')
        .replace(queryParameters: {'page': '$page', 'size': '$size'});
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final content = jsonDecode(res.body)['data']['content'] as List;
      return content.map((e) => NoticeItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createNotice({
    required String title,
    required String content,
    required String publishedAt,
  }) async {
    final res = await http.post(
      Uri.parse('${Store.baseUrl}/admin/notices'),
      headers: _headers,
      body: jsonEncode({'title': title, 'content': content, 'publishedAt': publishedAt}),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateNotice({
    required int id,
    required String title,
    required String content,
    required String publishedAt,
  }) async {
    final res = await http.put(
      Uri.parse('${Store.baseUrl}/admin/notices/$id'),
      headers: _headers,
      body: jsonEncode({'title': title, 'content': content, 'publishedAt': publishedAt}),
    );
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  Future<bool> deleteNotice(int id) async {
    final res = await http.delete(
      Uri.parse('${Store.baseUrl}/admin/notices/$id'),
      headers: _headers,
    );
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  // ── 문서 ───────────────────────────────────────────
  Future<List<DocumentItem>> getDocuments({int page = 0, int size = 20}) async {
    final uri = Uri.parse('${Store.baseUrl}/admin/documents')
        .replace(queryParameters: {'page': '$page', 'size': '$size'});
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final content = jsonDecode(res.body)['data']['content'] as List;
      return content.map((e) => DocumentItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> uploadDocument({
    required String title,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('${Store.baseUrl}/admin/documents'),
    )
      ..headers['Authorization'] = 'Bearer ${Store.token}'
      ..fields['title'] = title
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
    final res = await req.send();
    return res.statusCode == 201;
  }

  Future<bool> deleteDocument(int id) async {
    final res = await http.delete(
      Uri.parse('${Store.baseUrl}/admin/documents/$id'),
      headers: _headers,
    );
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  // ── LLM 엔드포인트 ─────────────────────────────────
  Future<List<LlmEndpoint>> getLlmEndpoints() async {
    final res = await http.get(
      Uri.parse('${Store.baseUrl}/admin/llm/endpoints'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'] as List;
      return data.map((e) => LlmEndpoint.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createLlmEndpoint(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${Store.baseUrl}/admin/llm/endpoints'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateLlmEndpoint(int id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('${Store.baseUrl}/admin/llm/endpoints/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  Future<bool> setDefaultLlmEndpoint(int id) async {
    final res = await http.post(
      Uri.parse('${Store.baseUrl}/admin/llm/endpoints/$id/default'),
      headers: _headers,
    );
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  Future<bool> deleteLlmEndpoint(int id) async {
    final res = await http.delete(
      Uri.parse('${Store.baseUrl}/admin/llm/endpoints/$id'),
      headers: _headers,
    );
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  // ── 감사 로그 ───────────────────────────────────────
  Future<List<LogItem>> getLogs({int page = 0, int size = 30}) async {
    final uri = Uri.parse('${Store.baseUrl}/admin/logs')
        .replace(queryParameters: {'page': '$page', 'size': '$size'});
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final content = jsonDecode(res.body)['data']['content'] as List;
      return content.map((e) => LogItem.fromJson(e)).toList();
    }
    return [];
  }
}
