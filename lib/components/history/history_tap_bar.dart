import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ion/enums/history_tap.dart';

import '../../store.dart';
import '../../utils.dart';

class HistoryTapBar extends StatefulWidget {
  const HistoryTapBar({
    super.key,
    required this.selectTap,
    required this.changeTap,
  });

  final HistoryTap selectTap;
  final Function(HistoryTap) changeTap;

  @override
  State<HistoryTapBar> createState() => _HistoryTapBarState();
}

class _HistoryTapBarState extends State<HistoryTapBar> {
  int chatsValue = 24;
  int savedValue = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Store.isLightMode.value
            ? Color(0xFFE2E2E2)
            : Color(0xFF3F424A)),
        color: Store.isLightMode.value
            ? Color(0xffEEEEEE)
            : Color(0xFF3F424A),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) => AnimatedAlign(
              alignment: widget.selectTap == HistoryTap.chats
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: SizedBox(
                height: double.infinity,
                width: constraints.maxWidth / 2,
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(0, 18),
                      child: Opacity(
                        opacity: 0.4,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 4,
                            sigmaY: 4,
                          ),
                          child: Container(
                            margin: EdgeInsetsGeometry.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Color(0xff1E1F22),
                                gradient: LinearGradient(
                                  stops: [0.32, 1],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Store.isLightMode.value
                                        ? Color(0xFF878787)
                                        : Color(0xff1E1F22),
                                    Store.isLightMode.value
                                        ? Color(0xFFE8E8E8)
                                        : Color(0xff1E1F22),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff1E1F22),
                      ),
                    ),
                  ],
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
  }

  Widget historyTabItem(String icon, HistoryTap tap, int value) {
    bool isSelected = widget.selectTap == tap;
    Color unselectedColor = Store.isLightMode.value
        ? Color(0xFF3B3B3B)
        : Color(0xFFEEEEEE);
    Color color = isSelected
        ? Color(0xFF14B48D)
        : unselectedColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => widget.changeTap(tap),
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
}
