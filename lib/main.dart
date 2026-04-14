import 'package:flutter/material.dart';
import 'package:ion/screens/home_page.dart';
import 'package:ion/store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ValueListenableBuilder(
      valueListenable: Store.isLightMode,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        );
      },
    ),
  );
}
