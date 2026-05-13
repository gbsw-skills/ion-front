import 'package:flutter/material.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/home_page.dart';
import 'package:ion/screens/login_screen.dart';
import 'package:ion/store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthRepository authRepository = AuthRepository();

  final accessToken = await authRepository.accessToken;

  Widget startScreen = HomePage();

  if(accessToken == null) startScreen = LoginScreen();

  runApp(
    ValueListenableBuilder(
      valueListenable: Store.isLightMode,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: startScreen,
        );
      },
    ),
  );
}
