import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/admin_page.dart';
import 'package:ion/screens/home_page.dart';
import 'package:ion/screens/login_screen.dart';
import 'package:ion/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final initialScreen = await _resolveInitialScreen();

      runApp(
        ValueListenableBuilder(
          valueListenable: Store.isLightMode,
          builder: (context, value, child) {
            return MaterialApp(
              theme: ThemeData(
                // textTheme: GoogleFonts.notoSansKrTextTheme(),
              ),
              debugShowCheckedModeBanner: false,
              home: initialScreen,
            );
          },
        ),
      );
    },
    // SSE 스트림 등 네트워크 연결이 중간에 끊길 때 발생하는 비동기 예외가
    // 콘솔에 "Uncaught (in promise)"로 노출되는 것을 막고 로그로만 남긴다.
    (error, stack) => debugPrint('[ZONE] Uncaught error: $error'),
  );
}

Future<Widget> _resolveInitialScreen() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final refreshToken = prefs.getString('refreshToken');

  if (accessToken == null || refreshToken == null) {
    return LoginScreen();
  }

  Store.token = accessToken;
  Store.refreshToken = refreshToken;
  Store.userRole = prefs.getString('userRole') ?? '';
  Store.displayName = prefs.getString('displayName') ?? '';
  Store.username = prefs.getString('username') ?? '';

  final result = await AuthRepository().refresh();
  if (result == 'success') {
    return Store.userRole == 'ADMIN' ? AdminPage() : HomePage();
  }

  await prefs.remove('accessToken');
  await prefs.remove('refreshToken');
  await prefs.remove('userRole');
  await prefs.remove('displayName');
  return LoginScreen();
}
