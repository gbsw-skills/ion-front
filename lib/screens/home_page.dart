import 'package:flutter/material.dart';
import 'package:ion/components/custom_history_bar.dart';
import 'package:ion/components/custom_side_bar.dart';
import 'package:ion/screens/chat_screen.dart';
import 'package:ion/screens/compass_screen.dart';
import 'package:ion/screens/filter_screen.dart';
import 'package:ion/screens/settings_screen.dart';
import 'package:ion/store.dart';
import 'package:ion/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final _breakpoint = 750.0;

  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_rebuild);
    Store.currentIndex.addListener(_rebuild);
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_rebuild);
    Store.currentIndex.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final index = Store.currentIndex.value;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showSidebars = constraints.maxWidth >= _breakpoint;
          return Row(
            children: [
              if (showSidebars) CustomSideBar(),
              if (showSidebars && index == 0) CustomHistoryBar(),
              _contentFor(index),
            ],
          );
        },
      ),
    );
  }

  Widget _contentFor(int index) {
    switch (index) {
      case 0:
        return ChatScreen();
      case 1:
        return FilterScreen();
      case 2:
        return CompassScreen();
      case 3:
        return SettingsScreen();
      default:
        return ChatScreen();
    }
  }
}
