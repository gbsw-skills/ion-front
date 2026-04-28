import 'package:flutter/cupertino.dart';
import 'package:ion/models/chat_model.dart';
import 'package:ion/models/chat_room_model.dart';

class Store {
  static ValueNotifier<bool> isLightMode = ValueNotifier(true);
  static int currentIndex = 0;
  static String baseUrl = 'https://ion.gbsw.hs.kr/api';
  static List<String> tabBarList = ['chat', 'filter', 'compass', 'settings'];
  static List<ChatRoomModel> chatList = [
    ChatRoomModel(
      title: "FastAPI 사용법",
      chatList: [
        ChatModel(
          isMine: true,
          content: "긴 텍스트",
        ),
        ChatModel(
          isMine: false,
          content: "네 알겠습니다",
        ),
        ChatModel(
          isMine: false,
          content: "좋은 질문이에요 👍  FastAPI에서 로그인 기능을 구현하려면 일반적으로 다음 과정을 따릅니다: 사용자 정보 확인 DB에서 사용자 ID와 비밀번호를 조회합니다. bcrypt 같은 라이브러리를 사용해 해시된 비밀번호를 비교합니다. JWT 토큰 발급 로그인 성공 시 JWT(JSON Web Token)을 생성하여 클라이언트에 전달합니다. 인증 처리 이후 요청에서는 토큰을 헤더에 포함시켜 인증을 수행합니다. 📌 FastAPI에서는 fastapi.security 모듈과 OAuth2PasswordBearer를 함께 사용하는 방식이 많이 활용됩니다.",
        ),
        ChatModel(
          isMine: true,
          content: "FastAPI로 로그인 기능을 구현하려면 어떻게 해야 하나요?",
        ),
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
    ChatRoomModel(
      title: "FastAPI 사용법",
      chatList: [
        ChatModel(
          isMine: true,
          content: "긴 텍스트",
        ),
        ChatModel(
          isMine: false,
          content: "네 알겠습니다",
        ),
        ChatModel(
          isMine: false,
          content: "좋은 질문이에요 👍  FastAPI에서 로그인 기능을 구현하려면 일반적으로 다음 과정을 따릅니다: 사용자 정보 확인 DB에서 사용자 ID와 비밀번호를 조회합니다. bcrypt 같은 라이브러리를 사용해 해시된 비밀번호를 비교합니다. JWT 토큰 발급 로그인 성공 시 JWT(JSON Web Token)을 생성하여 클라이언트에 전달합니다. 인증 처리 이후 요청에서는 토큰을 헤더에 포함시켜 인증을 수행합니다. 📌 FastAPI에서는 fastapi.security 모듈과 OAuth2PasswordBearer를 함께 사용하는 방식이 많이 활용됩니다.",
        ),
        ChatModel(
          isMine: true,
          content: "FastAPI로 로그인 기능을 구현하려면 어떻게 해야 하나요?",
        ),
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
    ChatRoomModel(
      title: "FastAPI 사용법",
      chatList: [
        ChatModel(
          isMine: true,
          content: "긴 텍스트",
        ),
        ChatModel(
          isMine: false,
          content: "네 알겠습니다",
        ), 
        ChatModel(
          isMine: false,
          content: "좋은 질문이에요 👍  FastAPI에서 로그인 기능을 구현하려면 일반적으로 다음 과정을 따릅니다: 사용자 정보 확인 DB에서 사용자 ID와 비밀번호를 조회합니다. bcrypt 같은 라이브러리를 사용해 해시된 비밀번호를 비교합니다. JWT 토큰 발급 로그인 성공 시 JWT(JSON Web Token)을 생성하여 클라이언트에 전달합니다. 인증 처리 이후 요청에서는 토큰을 헤더에 포함시켜 인증을 수행합니다. 📌 FastAPI에서는 fastapi.security 모듈과 OAuth2PasswordBearer를 함께 사용하는 방식이 많이 활용됩니다.",
        ),
        ChatModel(
          isMine: true,
          content: "FastAPI로 로그인 기능을 구현하려면 어떻게 해야 하나요?",
        ),
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
    ChatRoomModel(
      title: "FastAPI 사용법",
      chatList: [
        ChatModel(
          isMine: true,
          content: "긴 텍스트",
        ),
        ChatModel(
          isMine: false,
          content: "네 알겠습니다",
        ),
        ChatModel(
          isMine: false,
          content: "좋은 질문이에요 👍  FastAPI에서 로그인 기능을 구현하려면 일반적으로 다음 과정을 따릅니다: 사용자 정보 확인 DB에서 사용자 ID와 비밀번호를 조회합니다. bcrypt 같은 라이브러리를 사용해 해시된 비밀번호를 비교합니다. JWT 토큰 발급 로그인 성공 시 JWT(JSON Web Token)을 생성하여 클라이언트에 전달합니다. 인증 처리 이후 요청에서는 토큰을 헤더에 포함시켜 인증을 수행합니다. 📌 FastAPI에서는 fastapi.security 모듈과 OAuth2PasswordBearer를 함께 사용하는 방식이 많이 활용됩니다.",
        ),
        ChatModel(
          isMine: true,
          content: "FastAPI로 로그인 기능을 구현하려면 어떻게 해야 하나요?",
        ),
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
  static late String token;
  static late String refreshToken;
}
