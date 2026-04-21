import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ion/models/history_chat_model.dart';
import 'package:ion/store.dart';

class HistoryChatList extends StatefulWidget {
  const HistoryChatList({
    super.key,
    required this.selectedChatId,
    required this.changeChat,
  });

  final int selectedChatId;
  final Function(int) changeChat;

  @override
  State<HistoryChatList> createState() => _HistoryChatListState();
}

class _HistoryChatListState extends State<HistoryChatList> {
  final List<HistoryChatModel> historyChats = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await loadHistoryChats();
    },);
  }

  Future<void> loadHistoryChats() async {
    historyChats.clear();
    historyChats.addAll([
      HistoryChatModel(
        id: 4,
        isPinned: true,
        isSaved: false,
        lastMessageAt: DateTime.now(),
        title: 'FastAPI 사용법',
        content: '물론이죠! FastAPI는 Python에서 사용가능한 비동기 웹 프레임워크로...',
      ),
      HistoryChatModel(
        id: 3,
        isPinned: false,
        isSaved: false,
        lastMessageAt: DateTime.now().subtract(Duration(hours: 3)),
        title: 'FastAPI 사용법',
        content: '물론이죠! FastAPI는 Python에서 사용가능한 비동기 웹 프레임워크로...',
      ),
      HistoryChatModel(
        id: 2,
        isPinned: false,
        isSaved: false,
        lastMessageAt: DateTime(2026, 04, 11),
        title: 'FastAPI 사용법',
        content: '물론이죠! FastAPI는 Python에서 사용가능한 비동기 웹 프레임워크로',
      ),
      HistoryChatModel(
        id: 1,
        isPinned: false,
        isSaved: false,
        lastMessageAt: DateTime(2026, 03, 10),
        title: 'FastAPI 사용법FastAPI 사용법FastAPI 사용법FastAPI 사용법',
        content: 'FastAPI에서는 APIRouter를 사용하여 라우터를 모듈별로 분리할 수 있습니다.\n이를 통해 코드 구조를 깔끔하게 유지하고, 기능별로 API를 관리할 수 있습니다.\n예를 들어, 사용자 관련 API와 게시글 API를 각각 다른 파일로 나누어 관리할 수 있습니다.',
      ),
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ListView.separated(
        itemCount: historyChats.length,
        separatorBuilder: (context, index) => SizedBox(height: 10,),
        itemBuilder: (context, index) => chatItem(historyChats[index]),),
    ),
    );
  }

  Widget chatItem(HistoryChatModel chat) {
    final isSelected = widget.selectedChatId == chat.id;

    Color selectedBackground = Store.isLightMode.value
        ? Color(0xFFE3FEF7)
        : Color(0xFF1E1F22);
    Color title = Store.isLightMode.value
        ? Color(0xFF1E1F22)
        : Color(0xFFEEEEEE);
    Color dateColor = Store.isLightMode.value
        ? Color(0xFF9F9F9F)
        : Color(0x99ABABAB);
    Color contentColor = Store.isLightMode.value
        ? Color(0xFF6D717C)
        : isSelected ? Color(0xFFEEEEEE) : Color(0xFFABABAB);

    return GestureDetector(
      onTap: () => widget.changeChat(chat.id),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: 95,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? selectedBackground
              : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: SizedBox(
                width: 15,
                height: 15,
                child: chat.isPinned
                    ? SvgPicture.asset('assets/icons/union.svg')
                    : null,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  // 타이틀, 시간
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Text(
                          chat.title,
                          style: TextStyle(
                            fontSize: 15,
                            color: title,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(chat.displayTime, style: TextStyle(
                        fontSize: 12,
                        color: dateColor,
                        fontWeight: FontWeight.w400,
                      ), textAlign: TextAlign.left,),
                    ],
                  ),
                  // 내용
                  Text(
                    chat.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: contentColor,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16,),
          ],
        ),
      ),
    );
  }
}
