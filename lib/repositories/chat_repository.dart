import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ion/models/chat_session_model.dart';
import 'package:ion/store.dart';

class ChatRepository {
  Future<String> createSession() async {
    final response = await http.post(
      Uri.parse('${Store.baseUrl}/chat/sessions'),
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );

    if (response.statusCode == 201) {
      return 'success';
    }
    return 'fail';
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
}
