import 'package:flutter/material.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/home_page.dart';
import 'package:ion/screens/login_screen.dart';
import 'package:ion/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initialScreen = await _resolveInitialScreen();

  runApp(
    ValueListenableBuilder(
      valueListenable: Store.isLightMode,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: initialScreen,
        );
      },
    ),
  );
}

Future<Widget> _resolveInitialScreen() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final refreshToken = prefs.getString('refreshToken');

  if (accessToken == null || refreshToken == null) {
    return const LoginScreen();
  }

  Store.token = accessToken;
  Store.refreshToken = refreshToken;

  // refreshToken으로 토큰 갱신을 시도해 유효성 확인
  final result = await AuthRepository().refresh();
  if (result == 'success') {
    return const HomePage();
  }

  // 토큰이 만료됐으면 저장된 값 삭제 후 로그인 화면으로
  await prefs.remove('accessToken');
  await prefs.remove('refreshToken');
  return const LoginScreen();
}
