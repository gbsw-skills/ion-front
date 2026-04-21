import 'package:flutter/material.dart';
import 'package:ion/components/custom_history_bar.dart';
import 'package:ion/components/custom_side_bar.dart';
import 'package:ion/models/chat_model.dart';
import 'package:ion/store.dart';
import 'package:ion/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff1E1F22),
      body: Row(
        children: [
          CustomSideBar(),
          CustomHistoryBar(),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Color(0xffF5F5F5),
                  child: ListView.separated(
                    padding: .only(left: 80, right: 80, top: 120, bottom: 130),
                    itemCount: Store.chatList[0].chatList.length,
                    scrollDirection: .vertical,
                    separatorBuilder: (context, index) => SizedBox(height: 64),
                    itemBuilder: (context, index) {
                      final chat = Store.chatList[0].chatList[index];

                      return Stack(
                        children: [
                          Container(
                            padding: .symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: chat.isMine ? Color(0xffFFFFFF) : Color(0xffD8EFE9),
                              borderRadius: .circular(13)
                            ),
                            child: Text(chat.content),
                          ),
                          Transform.translate(
                            offset: Offset(-30, -30),
                            child: Row(
                              children: [
                                chat.isMine ? Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Color(0xff10A37F),
                                    borderRadius: .circular(10),
                                    image: DecorationImage(image: AssetImage('assets/images/user.png'), fit: .cover, onError: (exception, stackTrace) => SizedBox()),
                                  ),
                                ) : Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Color(0xff10A37F),
                                    borderRadius: .circular(10),
                                    image: DecorationImage(image: AssetImage('assets/images/chat_gpt.png'), fit: .cover, onError: (exception, stackTrace) => SizedBox()),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Transform.translate(offset: Offset(0, -8), child: Text(chat.isMine ? 'You' : 'Response', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: .w800))),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Align(
                  alignment: .bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 44),
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Container(
                          width: 800,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Color(0xffFFFFFF),
                            borderRadius: .circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 14),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Color(0xffE7E9F0),
                                  borderRadius: .circular(8)
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _chatController,
                                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                                  onSubmitted: (value) {
                                    Store.chatList[0].chatList.add(ChatModel(isMine: true, content: _chatController.text));
                                    _chatController.clear();
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: .symmetric(horizontal: 14),
                                    hintText: 'Ask questions, or type ‘/’ for commands',
                                    hintStyle: TextStyle(color: Color(0xffA0A7BB)),
                                    border: .none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Color(0xffFFFFFF),
                            borderRadius: .circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
