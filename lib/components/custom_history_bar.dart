import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ion/components/history/history_tap_bar.dart';
import 'package:ion/enums/history_tap.dart';
import 'package:ion/store.dart';
import 'package:ion/theme/app_colors.dart';

import '../utils.dart';
import 'history/history_chat_list.dart';

class CustomHistoryBar extends StatefulWidget {
  CustomHistoryBar({super.key});

  @override
  State<CustomHistoryBar> createState() => _CustomHistoryBarState();
}

class _CustomHistoryBarState extends State<CustomHistoryBar> {
  final _listKey = GlobalKey<HistoryChatListState>();
  final _searchController = TextEditingController();
  String selectedChatId = Store.selectedSessionId.value;
  HistoryTap selectTap = HistoryTap.chats;
  int _chatsCount = 0;
  int _savedCount = 0;
  String _searchQuery = '';
  bool _sortNewest = true;

  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_rebuild);
    Store.selectedSessionId.addListener(_onSessionIdChanged);
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_rebuild);
    Store.selectedSessionId.removeListener(_onSessionIdChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _onSessionIdChanged() {
    setState(() => selectedChatId = Store.selectedSessionId.value);
  }

  void changeTap(HistoryTap tap) {
    setState(() {
      selectTap = tap;
    });
  }

  void changeChat(String id) {
    setState(() {
      selectedChatId = id;
    });
    Store.selectedSessionId.value = id;
  }

  void _createSession() {
    Store.selectedSessionId.value = '';
    Store.selectedSessionTitle.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      width: 350,
      height: sizeh(context),
      color: AppColors.pageBackground,
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              spacing: 20,
              children: [
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    Text(
                      '기록',
                      style: TextStyle(
                        color: AppColors.historyTitle,
                        fontSize: 22,
                        fontWeight: .w700,
                      ),
                    ),
                    Spacer(),
                    newBtn(),
                    SizedBox(width: 14),
                    menuBtn(),
                  ],
                ),
                HistoryTapBar(
                  changeTap: changeTap,
                  selectTap: selectTap,
                  chatsCount: _chatsCount,
                  savedCount: _savedCount,
                ),
                searchFilterBar(),
              ],
            ),
          ),
          HistoryChatList(
            key: _listKey,
            selectedChatId: selectedChatId,
            changeChat: changeChat,
            selectTap: selectTap,
            searchQuery: _searchQuery,
            sortNewest: _sortNewest,
            onCountsChanged: (chats, saved) => setState(() {
              _chatsCount = chats;
              _savedCount = saved;
            }),
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
        color: AppColors.searchBarBackground.withValues(alpha: 0.25),
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
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
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
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Icon(Icons.close, size: 14, color: Color(0xFF575B65)),
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

  Widget filterBtn() => PopupMenuButton<bool>(
    padding: EdgeInsets.zero,
    offset: Offset(0, 42),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    color: AppColors.dialogBackground,
    elevation: 4,
    onSelected: (newest) => setState(() => _sortNewest = newest),
    itemBuilder: (_) => [
      PopupMenuItem(
        value: true,
        height: 36,
        child: Row(
          spacing: 8,
          children: [
            SizedBox(
              width: 14,
              child: _sortNewest
                  ? Icon(Icons.check, size: 14, color: AppColors.accent)
                  : null,
            ),
            Text('최신순', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
      ),
      PopupMenuItem(
        value: false,
        height: 36,
        child: Row(
          spacing: 8,
          children: [
            SizedBox(
              width: 14,
              child: !_sortNewest
                  ? Icon(Icons.check, size: 14, color: AppColors.accent)
                  : null,
            ),
            Text('제목순', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
      ),
    ],
    child: Container(
      padding: EdgeInsets.all(9),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _sortNewest
            ? AppColors.historyIconBoxBackground
            : AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: _sortNewest
            ? null
            : Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1),
      ),
      child: SvgPicture.asset('assets/icons/search_filter.svg'),
    ),
  );

  Widget newBtn() => GestureDetector(
    onTap: _createSession,
    child: Container(
      padding: EdgeInsets.all(10),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Color(0xff23C69E),
        borderRadius: .circular(10),
      ),
      child: SvgPicture.asset('assets/icons/add.svg'),
    ),
  );

  Widget menuBtn() => Container(
    padding: EdgeInsets.all(9),
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: AppColors.historyIconBoxBackground,
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
