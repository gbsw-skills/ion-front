import 'package:flutter/cupertino.dart';
import 'package:ion/models/chat_model.dart';
import 'package:ion/models/chat_room_model.dart';

class Store {
  static ValueNotifier<bool> isLightMode = ValueNotifier(true);
  static int currentIndex = 0;
  static List<String> tabBarList = ['chat', 'filter', 'compass', 'settings'];
  static List<ChatRoomModel> chatList = [
    ChatRoomModel(
      title: "FastAPI 사용법",
      chatList: [
        ChatModel(
          isMine: true,
          content: "FastAPI에서 라우터를 어떻게 분리하나요?",
        ),
        ChatModel(
          isMine: true,
          content: "FastAPI에서 라우터를 어떻게 분리하나요?",
        ),
      ],
    ),
  ];
}
