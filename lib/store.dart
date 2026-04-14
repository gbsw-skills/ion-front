import 'package:flutter/cupertino.dart';
import 'package:ion/models/chat_model.dart';
import 'package:ion/models/chat_room_model.dart';

class Store {
  static ValueNotifier<bool> isLightMode = ValueNotifier(true);
  static List<ChatRoomModel> chatList = [
    ChatRoomModel(
      title: "FastAPI 사용법",
      chatList: [
        ChatModel(
          id: 1,
          user: "You",
          content: "FastAPI에서 라우터를 어떻게 분리하나요?",
        ),
        ChatModel(
          id: 2,
          user: "Response",
          content: "FastAPI에서는 APIRouter를 사용하여 라우터를 모듈별로 분리할 수 있습니다.  이를 통해 코드 구조를 깔끔하게 유지하고, 기능별로 API를 관리할 수 있습니다. 예를 들어, 사용자 관련 API와 게시글 API를 각각 다른 파일로 나누어 관리할 수 있습니다.",
        ),
      ],
    ),
  ];
}
