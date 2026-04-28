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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff282A2E),
      body: Row(
        children: [
          CustomSideBar(),
          CustomHistoryBar(),
          ChatScreen(),
        ],
      ),
    );
  }
}
