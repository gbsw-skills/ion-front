import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/admin_page.dart';
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
          theme: ThemeData(
            // textTheme: GoogleFonts.notoSansKrTextTheme(),
          ),
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
  Store.userRole = prefs.getString('userRole') ?? '';
  Store.displayName = prefs.getString('displayName') ?? '';
  Store.username = prefs.getString('username') ?? '';

  final result = await AuthRepository().refresh();
  if (result == 'success') {
    return Store.userRole == 'ADMIN' ? const AdminPage() : const HomePage();
  }

  await prefs.remove('accessToken');
  await prefs.remove('refreshToken');
  await prefs.remove('userRole');
  await prefs.remove('displayName');
  return const LoginScreen();
}
