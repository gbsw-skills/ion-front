import 'package:flutter/material.dart';
import 'package:ion/components/custom_history_bar.dart';
import 'package:ion/components/custom_side_bar.dart';
import 'package:ion/models/chat_model.dart';
import 'package:ion/screens/chat_screen.dart';
import 'package:ion/store.dart';
import 'package:ion/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _breakpoint = 750.0;

  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff282A2E),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showSidebars = constraints.maxWidth >= _breakpoint;
          return Row(
            children: [
              if (showSidebars) CustomSideBar(),
              if (showSidebars) CustomHistoryBar(),
              ChatScreen(),
            ],
          );
        },
      ),
    );
  }
}
