import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ion/models/chat_model.dart';
import 'package:ion/models/chat_session_model.dart';
import 'package:ion/store.dart';

void _log(String msg) => debugPrint('[CHAT] $msg');

class ChatRepository {
  Future<ChatSession?> createSession() async {
    final url = Uri.parse('${Store.baseUrl}/chat/sessions');
    _log('POST $url');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    _log('POST $url → ${response.statusCode}');
    if (response.body.isNotEmpty) _log('body: ${response.body}');

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return ChatSession.fromJson(body['data']);
    }
    return null;
  }

  Future<List<ChatSession>> getSessions({int page = 0, int size = 20}) async {
    final uri = Uri.parse('${Store.baseUrl}/chat/sessions')
        .replace(queryParameters: {'page': '$page', 'size': '$size'});
    _log('GET $uri');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    _log('GET $uri → ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['data']['content'] as List;
      _log('sessions count: ${content.length}');
      return content.map((e) => ChatSession.fromJson(e)).toList();
    }
    _log('getSessions failed: ${response.body}');
    return [];
  }

  Future<List<ChatModel>> getMessages(String sessionId) async {
    final uri = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId/messages')
        .replace(queryParameters: {'page': '0', 'size': '50'});
    _log('GET $uri');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    _log('GET $uri → ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['data']['content'] as List;
      _log('messages count: ${content.length}');
      return content
          .map((e) => ChatModel(
                isMine: e['role'] == 'user',
                content: (e['content'] as String?) ?? '',
              ))
          .toList();
    }
    _log('getMessages failed: ${response.body}');
    return [];
  }

  Future<bool> deleteSession(String sessionId) async {
    final url = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId');
    _log('DELETE $url');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    _log('DELETE $url → ${response.statusCode}');
    if (response.body.isNotEmpty) _log('body: ${response.body}');
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> sendMessage(String sessionId, String content) async {
    final url = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId/messages');
    _log('POST $url  content="${content.length > 50 ? '${content.substring(0, 50)}...' : content}"');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Store.token}',
      },
      body: jsonEncode({'content': content}),
    );
    _log('POST $url → ${response.statusCode}');
    if (response.body.isNotEmpty) _log('body: ${response.body}');
    return response.statusCode == 202;
  }

  Stream<String> streamResponse(String sessionId) async* {
    final uri = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId/stream');
    _log('SSE CONNECT $uri');
    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      request.headers['Authorization'] = 'Bearer ${Store.token}';
      request.headers['Accept'] = 'text/event-stream';
      final streamed = await client.send(request);
      _log('SSE → ${streamed.statusCode}');

      String eventType = '';
      final buffer = StringBuffer();

      await for (final line in streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.startsWith('event:')) {
          eventType = line.substring(6).trim();
          _log('SSE event: $eventType');
        } else if (line.startsWith('data:')) {
          final data = line.substring(5).trim();
          if (eventType == 'token') {
            final json = jsonDecode(data);
            final token = json['token'] as String;
            buffer.write(token);
            yield token;
          } else if (eventType == 'done') {
            _log('SSE done — total tokens: "${buffer.toString().length}" chars');
            return;
          } else if (eventType == 'error') {
            _log('SSE error: $data');
            return;
          }
        }
      }
      _log('SSE stream ended');
    } catch (e) {
      _log('SSE exception: $e');
      rethrow;
    } finally {
      client.close();
      _log('SSE client closed');
    }
  }
}
