import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  int chatsValue = 24;
  int savedValue = 24;

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
          historyTabBar(),
        ],
      ),
    );
  }

  Widget historyTabItem(String icon, HistoryTap tap, int value) {
    bool isSelected = selectTap == tap;
    Color color = isSelected
        ? Color(0xFF14B48D)
        : secondaryTextColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => changeTap(tap),
        child: SizedBox(
          height: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              SizedBox(
                height: 13,
                width: 13,
                child: SvgPicture.asset(
                  'assets/icons/$icon.svg',
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              Text(tap.label, style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),),
              IntrinsicHeight(
                child: Container(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: color.withValues(alpha: 0.11)
                  ),
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget historyTabBar() => Container(
    padding: EdgeInsets.all(5),
    width: double.infinity,
    height: 55,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: tabBtnBackgroundColor,
    ),
    child: Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => AnimatedAlign(
            alignment: selectTap == HistoryTap.chats
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Container(
              height: double.infinity,
              width: constraints.maxWidth / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: backgroundColor,
              ),
            ),
          ),
        ),
        Row(
          children: [
            historyTabItem('chat_filled', HistoryTap.chats, chatsValue),
            historyTabItem('flag_filled', HistoryTap.saved, chatsValue),
          ],
        ),
      ],
    ),
  );

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
