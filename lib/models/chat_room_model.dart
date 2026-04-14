import 'package:ion/models/chat_model.dart';

class ChatRoomModel {
  final String title;
  final List<ChatModel> chatList;

  ChatRoomModel({
    required this.title,
    required this.chatList,
  });
}
