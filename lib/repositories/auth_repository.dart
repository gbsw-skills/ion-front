import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ion/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<String> login(String username, String password) async {
    final body = {
      "username": username,
      "password": password,
    };
    final response = await http.post(
      Uri.parse('${Store.baseUrl}/auth/login'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final data = responseData['data'];
      Store.token = data['accessToken'];
      Store.refreshToken = data['refreshToken'];
      Store.userRole = data['user']['role'] ?? '';
      Store.displayName = data['user']['displayName'] ?? '';
      Store.username = data['user']['username'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', Store.token);
      await prefs.setString('refreshToken', Store.refreshToken);
      await prefs.setString('userRole', Store.userRole);
      await prefs.setString('displayName', Store.displayName);
      await prefs.setString('username', Store.username);
      debugPrint('[AUTH] accessToken: ${Store.token}');
      debugPrint('[AUTH] refreshToken: ${Store.refreshToken}');
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
      Uri.parse('${Store.baseUrl}/auth/refresh'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Store.token = responseData['data']['accessToken'];
      Store.refreshToken = responseData['data']['refreshToken'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', Store.token);
      await prefs.setString('refreshToken', Store.refreshToken);
      return 'success'; // 성공
    }
    if (response.statusCode == 401) {
      return "invalid"; // Refresh Token 만료 또는 무효
    }
    return 'fail'; // 실패
  }

  Future<String> logout() async {
    final response = await http.post(
      Uri.parse('${Store.baseUrl}/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Store.token}',
      },
    );

    Store.userRole = '';
    Store.displayName = '';
    Store.username = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userRole');
    await prefs.remove('displayName');
    await prefs.remove('username');

    if (response.statusCode == 200) {
      return 'success'; // 성공
    }
    return 'fail'; // 실패
  }
}
