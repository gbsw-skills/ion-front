import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ion/store.dart';

class AuthRepository {
  Future<String> login(String username, String password) async {
    final body = {
      "username": username,
      "password": password,
    };
    final response = await http.post(
      Uri.parse('https://ion.gbsw.hs.kr/api/auth/login'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Store.token = responseData['data']['accessToken'];
      Store.refreshToken = responseData['data']['refreshToken'];
      return 'success'; // 성공
    }
    if (response.statusCode == 401) {
      return 'different'; // 아이디/비밀번호 불일치
    }
    return 'fail'; // 실패
  }

  Future<String> refresh() async {
    final body = {'refreshToken': Store.refreshToken};
    final response = await http.post(
        Uri.parse('https://ion.gbsw.hs.kr/api/auth/refresh'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Store.token = responseData['data']['accessToken'];
      Store.refreshToken = responseData['data']['refreshToken'];
      return 'success'; // 성공
    }
    if (response.statusCode == 401) {
      return "invalid"; // Refresh Token 만료 또는 무효
    }
    return 'fail'; // 실패
  }

  Future<String> logout() async {
    final response = await http.post(
        Uri.parse('https://ion.gbsw.hs.kr/api/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Store.token}'
        }
    );

    if (response.statusCode == 200) {
      return 'success'; // 성공
    }
    return 'fail'; // 실패
  }
}
