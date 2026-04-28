import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ion/components/history/history_tap_bar.dart';
import 'package:ion/enums/history_tap.dart';
import 'package:ion/store.dart';

import '../utils.dart';
import 'history/history_chat_list.dart';

class CustomHistoryBar extends StatefulWidget {
  const CustomHistoryBar({super.key});

  @override
  State<CustomHistoryBar> createState() => _CustomHistoryBarState();
}

class _CustomHistoryBarState extends State<CustomHistoryBar> {
  int selectedChatId = 0; // 나중에 좀 더 상위단으로 올려야 할듯
  HistoryTap selectTap = HistoryTap.chats;

  void changeTap(HistoryTap tap) {
    setState(() {
      selectTap = tap;
    });
  }

  void changeChat(int id) {
    setState(() {
      selectedChatId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      width: 350,
      height: sizeh(context),
      color: Store.isLightMode.value
          ? Color(0xffFFFFFF)
          : Color(0xff282A2E),
      child: Column(
        spacing: 20,
        children: [
          Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16.0),
           child: Column(
             spacing: 20,
             children: [
               Row(
                 mainAxisAlignment: .center,
                 children: [
                   Text('기록', style: TextStyle(
                       color: Store.isLightMode.value ? Color(0xFF1E1F22) : Colors.white,
                       fontSize: 22,
                       fontWeight: .w700),
                   ),
                   Spacer(),
                   newBtn(),
                   SizedBox(width: 14),
                   menuBtn(),
                 ],
               ),
               HistoryTapBar(
                 changeTap: (tap) => changeTap(tap),
                 selectTap: selectTap,
               ),
               searchFilterBar(),
             ],
           ),
          ),
          HistoryChatList(
            selectedChatId: selectedChatId,
            changeChat: (id) => changeChat(id),
          ),
        ],
      ),
    );
  }

  Widget searchBar() => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      height: 37,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: (Store.isLightMode.value
            ? Color(0xFFD6D6D6)
            : Color(0xFF3F424A)).withValues(alpha: 0.25),
      ),
      child: Row(
        spacing: 5,
        children: [
          SizedBox(
            width: 15,
            child: SvgPicture.asset('assets/icons/search.svg'),
          ),
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF575B65),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget searchFilterBar() => Row(
    spacing: 12,
    children: [
      searchBar(),
      filterBtn(),
    ],
  );

  Widget filterBtn() => Container(
    padding: EdgeInsets.all(9),
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Store.isLightMode.value
          ? Color(0xffEFEFEF)
          : Color(0xff1E1F22),
      borderRadius: .circular(10),
    ),
    child: SvgPicture.asset('assets/icons/search_filter.svg',),
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
          : Color(0xff1E1F22),
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
