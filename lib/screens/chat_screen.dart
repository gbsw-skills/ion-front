import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/chat_model.dart';
import '../models/chat_room_model.dart';
import '../store.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  ChatRoomModel? chatData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadChat();
    },);
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> loadChat() async {
    setState(() {
      chatData = Store.chatList[0];
    });
  }

  Future<void> sendChat(String message) async {
    setState(() {
      chatData?.chatList.insert(0, ChatModel(isMine: true, content: message));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        spacing: 4,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 27),
                child: Text(chatData?.title ?? '', style: TextStyle(
                  fontSize: 22,
                  color: Store.isLightMode.value
                      ? Color(0xFF1E1F22)
                      : Color(0xFFEEEEEE),
                  fontWeight: FontWeight.bold,
                ),),
              ),
            ],
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 18, bottom: 18),
              alignment: Alignment.center,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Store.isLightMode.value
                    ? Color(0xffF5F5F5)
                    : Color(0xFF3F424A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  chatMessageList(),
                  chatInputFiled(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatInputFiled() {
    final backgroundColor = Store.isLightMode.value
        ? Colors.white
        : Color(0xFF4B4F5B);

    return Align(
      alignment: .bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 14),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 980,
          ),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  height: 55,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: .circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Store.isLightMode.value
                            ? Color(0x0d1e1f22)
                            : Color(0x331e1f22),
                        blurRadius: 29,
                        offset: Offset(0, 19),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: Store.isLightMode.value
                                ? Color(0xffE7E9F0)
                                : Color(0xff404450),
                            borderRadius: .circular(8)
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          onTapOutside: (event) => FocusScope.of(context).unfocus(),
                          onSubmitted: (value) {
                            sendChat(_chatController.text);
                            _chatController.clear();
                            setState(() {});
                          },
                          style: TextStyle(
                            fontSize: 14,
                            color: Store.isLightMode.value
                                ? Color(0xFF1E1F22)
                                : Color(0xFFEEEEEE),
                          ),
                          decoration: InputDecoration(
                            contentPadding: .symmetric(horizontal: 14),
                            hintText: 'Ask questions, or type ‘/’ for commands',
                            hintStyle: TextStyle(color: Color(0xffA0A7BB)),
                            border: .none,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: SvgPicture.asset('assets/icons/send.svg'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 24),
              Container(
                alignment: Alignment.center,
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: .circular(8),
                ),
                child: SizedBox(
                  height: 20,
                  child: SvgPicture.asset('assets/icons/mike.svg'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageItem(ChatModel chat) {
    final darkBackground = chat.isMine ? Color(0xff4B4F5B) : Color(0xff28303F);
    final lightBackground = chat.isMine ? Color(0xffFFFFFF) : Color(0xffD8EFE9);

    return Stack(
      children: [
        Container(
          padding: .symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
              color: Store.isLightMode.value
                  ? lightBackground
                  : darkBackground,
              borderRadius: .circular(10)
          ),
          child: Text(chat.content, style: TextStyle(
            fontSize: 14,
            color: Store.isLightMode.value
                ? Color(0xFF1E1F22)
                : Color(0xFFEEEEEE),
          ),),
        ),
        Transform.translate(
          offset: Offset(-30, -30),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: chat.isMine ? Colors.transparent : Color(0xff10A37F),
                  borderRadius: .circular(10),
                  image: DecorationImage(image: AssetImage('assets/images/${chat.isMine ? 'user' : 'chat_gpt'}.png'), fit: .cover, onError: (exception, stackTrace) => SizedBox()),
                ),
              ),
              SizedBox(width: 10),
              Transform.translate(
                offset: Offset(0, -8),
                child: Text(chat.isMine
                    ? 'You'
                    : 'Response',
                  style: TextStyle(color: Store.isLightMode.value
                      ? Color(0xFF1E1F22)
                      : Color(0xFFEEEEEE), fontSize: 15, fontWeight: .w800,),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget chatMessageList() => SizedBox(
    height: double.infinity,
    child: ListView.separated(
      reverse: true,
      padding: .only(top: 60, bottom: 130, left: 30, right: 30),
      itemCount: (chatData?.chatList ?? []).length,
      scrollDirection: .vertical,
      separatorBuilder: (context, index) => SizedBox(height: 64),
      itemBuilder: (context, index) {
        final chat = chatData!.chatList[index];

        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            constraints: BoxConstraints(
              maxWidth: 950,
            ),
            child: messageItem(chat),
          ),
        );
      },
    ),
  );
}
