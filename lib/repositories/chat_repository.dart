import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ion/store.dart';

class ChatRepository {
  Future<String> createSessions() async {
    final response = await http.post(
      Uri.parse('https://ion.gbsw.hs.kr/api/chat/sessions'),
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );

    if (response.statusCode == 201) {
      return 'success'; // 성공
    }
    return 'fail'; // 실패
  }

  Future<String> searchSessions() async {
    final response = await http.get(
      Uri.parse('https://ion.gbsw.hs.kr/api/v1/chat/sessions'),
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return 'success';
    }

    return 'fail';
  }
}
