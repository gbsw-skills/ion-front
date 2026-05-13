import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ion/enums/request_code.dart';
import 'package:ion/store.dart';

class AuthRepository {
  final storage = FlutterSecureStorage();

  Future<RequestCode> login(String username, String password) async {
    try {
      final body = {
        "username": username,
        "password": password,
      };
      final response = await http.post(
          Uri.parse('${Store.baseUrl}/auth/login'),
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'}
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await setAccessToken(responseData['data']['accessToken']);
        await setRefreshToken(responseData['data']['refreshToken']);
        final userData = {
          "accessToken": await accessToken,
          "refreshToken": await refreshToken,
          "id": responseData['id'],
          "username": responseData['username'],
          "displayName": responseData['displayName'],
          "role": responseData['role'],
        };

        await storage.write(key: 'userData', value: jsonEncode(userData));

        return RequestCode.SUCCESS; // 성공
      }

      return Store.handleError(response.statusCode, responseData['error']);
    } catch(e) {
      print('로그인 에러: $e');
      return RequestCode.FAIL; // 실패
    }
  }

  Future<RequestCode> refresh() async {
    try {
      final body = {'refreshToken': refreshToken};
      final response = await http.post(
          Uri.parse('${Store.baseUrl}/auth/refresh'),
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'}
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await setAccessToken(responseData['data']['accessToken']);
        await setRefreshToken(responseData['data']['refreshToken']);
        return RequestCode.SUCCESS; // 성공
      }

      deleteAccessToken();
      deleteRefreshToken();

      return Store.handleError(response.statusCode, responseData['error']);
    } catch(e) {
      print('refresh 에러: $e');
      return RequestCode.FAIL; // 실패
    }
  }

  Future<RequestCode> logout() async {
    try {
      final response = await http.post(
          Uri.parse('${Store.baseUrl}/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          }
      );

      if (response.statusCode == 200) {
        deleteAccessToken();
        deleteRefreshToken();
        return RequestCode.SUCCESS; // 성공
      }
    } catch(e) {
      print('로그아웃 에러: $e');
      } finally {
        return RequestCode.FAIL; // 실패
    }
  }

  Future<String?> get accessToken => storage.read(key: 'accessToken');
  Future<String?> get refreshToken => storage.read(key: 'refreshToken');

  Future<void> setAccessToken(String accessToken) async {
    await storage.write(key: 'accessToken', value: accessToken);
  }

  Future<void> deleteAccessToken() async {
    await storage.delete(key: 'accessToken');
  }

  Future<void> setRefreshToken(String refreshToken) async {
    await storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await storage.delete(key: 'refreshToken');
  }
}
