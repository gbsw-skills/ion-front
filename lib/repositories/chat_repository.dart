import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ion/models/chat_model.dart';
import 'package:ion/models/chat_session_model.dart';
import 'package:ion/store.dart';

class ChatRepository {
  Future<ChatSession?> createSession() async {
    final response = await http.post(
      Uri.parse('${Store.baseUrl}/chat/sessions'),
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return ChatSession.fromJson(body['data']);
    }
    return null;
  }

  Future<List<ChatSession>> getSessions({int page = 0, int size = 20}) async {
    final uri = Uri.parse('${Store.baseUrl}/chat/sessions')
        .replace(queryParameters: {'page': '$page', 'size': '$size'});
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['data']['content'] as List;
      return content.map((e) => ChatSession.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ChatModel>> getMessages(String sessionId) async {
    final uri = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId/messages')
        .replace(queryParameters: {'page': '0', 'size': '50'});
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['data']['content'] as List;
      return content
          .map((e) => ChatModel(
                isMine: e['role'] == 'user',
                content: e['content'] as String,
              ))
          .toList();
    }
    return [];
  }

  Future<bool> deleteSession(String sessionId) async {
    final url = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> sendMessage(String sessionId, String content) async {
    final response = await http.post(
      Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Store.token}',
      },
      body: jsonEncode({'content': content}),
    );
    return response.statusCode == 202;
  }

  Stream<String> streamResponse(String sessionId) async* {
    final uri =
        Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId/stream');
    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      request.headers['Authorization'] = 'Bearer ${Store.token}';
      request.headers['Accept'] = 'text/event-stream';
      final streamed = await client.send(request);

      String eventType = '';
      await for (final line in streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.startsWith('event:')) {
          eventType = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          final data = line.substring(5).trim();
          if (eventType == 'token') {
            final json = jsonDecode(data);
            yield json['token'] as String;
          } else if (eventType == 'done' || eventType == 'error') {
            return;
          }
        }
      }
    } finally {
      client.close();
    }
  }
}
