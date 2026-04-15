import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ion/components/history/history_tap_bar.dart';
import 'package:ion/enums/history_tap.dart';
import 'package:ion/store.dart';

import '../utils.dart';

class CustomHistoryBar extends StatefulWidget {
  const CustomHistoryBar({super.key});

  @override
  State<CustomHistoryBar> createState() => _CustomHistoryBarState();
}

class _CustomHistoryBarState extends State<CustomHistoryBar> {
  HistoryTap selectTap = HistoryTap.chats;

  void changeTap(HistoryTap tap) {
    setState(() {
      selectTap = tap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 350,
      height: sizeh(context),
      color: secondaryBackgroundColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: .center,
            children: [
              Text('기록', style: TextStyle(
                color: Store.isLightMode.value ? Colors.black : Colors.white,
                fontSize: 22,
                fontWeight: .w700),
              ),
              Spacer(),
              newBtn(),
              SizedBox(width: 14),
              menuBtn(),
            ],
          ),
          SizedBox(height: 20,),
          HistoryTapBar(
            changeTap: (tap) => changeTap(tap),
            selectTap: selectTap,
          ),
        ],
      ),
    );
  }

  Widget newBtn() => Container(
    padding: EdgeInsets.all(10),
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Color(0xff23C69E),
      borderRadius: .circular(10),
    ),
    child: SvgPicture.asset('assets/icons/add.svg'),
  );

  Widget menuBtn() => Container(
    padding: EdgeInsets.all(9),
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Store.isLightMode.value
          ? Color(0xffEFEFEF)
          : backgroundColor,
      borderRadius: .circular(10),
    ),
    child: SvgPicture.asset(
      'assets/icons/menu.svg',
      colorFilter: Store.isLightMode.value
          ? null
          : ColorFilter.mode(Color(0xFFD9D9D9), BlendMode.srcIn),
    ),
  );
}
