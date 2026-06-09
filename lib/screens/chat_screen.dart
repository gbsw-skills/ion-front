import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ion/repositories/chat_repository.dart';

import '../models/chat_model.dart';
import '../store.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final _repo = ChatRepository();

  List<ChatModel> _messages = [];
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    Store.selectedSessionId.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    Store.selectedSessionId.removeListener(_onSessionChanged);
    _chatController.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    setState(() => _messages = []);
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final sessionId = Store.selectedSessionId.value;
    if (sessionId.isEmpty) return;
    final messages = await _repo.getMessages(sessionId);
    if (!mounted) return;
    // API는 오래된 순으로 반환 → reverse로 최신이 index 0에 오도록
    setState(() => _messages = messages.reversed.toList());
  }

  Future<void> _sendChat(String content) async {
    if (content.trim().isEmpty) return;
    final sessionId = Store.selectedSessionId.value;
    if (sessionId.isEmpty || _isStreaming) return;

    _chatController.clear();

    setState(() {
      _messages.insert(0, ChatModel(isMine: true, content: content));
      _isStreaming = true;
    });

    final sent = await _repo.sendMessage(sessionId, content);
    if (!mounted) return;
    if (!sent) {
      setState(() => _isStreaming = false);
      return;
    }

    // AI 응답 자리 확보
    setState(() {
      _messages.insert(0, ChatModel(isMine: false, content: ''));
    });

    // SSE 스트리밍으로 토큰 수신
    await for (final token in _repo.streamResponse(sessionId)) {
      if (!mounted) return;
      setState(() {
        _messages[0] = ChatModel(
          isMine: false,
          content: _messages[0].content + token,
        );
      });
    }

    if (mounted) setState(() => _isStreaming = false);
  }

  @override
  Widget build(BuildContext context) {
    final title = Store.selectedSessionTitle.value;

    return Expanded(
      child: Column(
        spacing: 4,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 27),
                child: Text(
                  title.isEmpty ? '채팅방을 선택해주세요' : title,
                  style: TextStyle(
                    fontSize: 22,
                    color: Store.isLightMode.value
                        ? Color(0xFF1E1F22)
                        : Color(0xFFEEEEEE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
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
                  _chatMessageList(),
                  _chatInputField(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatInputField() {
    final backgroundColor =
        Store.isLightMode.value ? Colors.white : Color(0xFF4B4F5B);
    final canSend = Store.selectedSessionId.value.isNotEmpty && !_isStreaming;

    return Align(
      alignment: .bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 14),
        child: Container(
          constraints: BoxConstraints(maxWidth: 980),
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
                          borderRadius: .circular(8),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          enabled: canSend,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          onSubmitted: (value) => _sendChat(value),
                          style: TextStyle(
                            fontSize: 14,
                            color: Store.isLightMode.value
                                ? Color(0xFF1E1F22)
                                : Color(0xFFEEEEEE),
                          ),
                          decoration: InputDecoration(
                            contentPadding: .symmetric(horizontal: 14),
                            hintText: canSend
                                ? 'Ask questions, or type \'/\' for commands'
                                : '채팅방을 선택해주세요',
                            hintStyle: TextStyle(color: Color(0xffA0A7BB)),
                            border: .none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: canSend
                            ? () => _sendChat(_chatController.text)
                            : null,
                        child: SizedBox(
                          width: 30,
                          child: SvgPicture.asset(
                            'assets/icons/send.svg',
                            colorFilter: canSend
                                ? null
                                : ColorFilter.mode(
                                    Color(0xffA0A7BB), BlendMode.srcIn),
                          ),
                        ),
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

  Widget _messageItem(ChatModel chat) {
    final darkBackground =
        chat.isMine ? Color(0xff4B4F5B) : Color(0xff28303F);
    final lightBackground =
        chat.isMine ? Color(0xffFFFFFF) : Color(0xffD8EFE9);

    return Stack(
      children: [
        Container(
          padding: .symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Store.isLightMode.value ? lightBackground : darkBackground,
            borderRadius: .circular(10),
          ),
          child: chat.isMine
              ? Text(
                  chat.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Store.isLightMode.value
                        ? Color(0xFF1E1F22)
                        : Color(0xFFEEEEEE),
                  ),
                )
              : chat.content.isEmpty
                  ? _streamingIndicator()
                  : MarkdownBody(
                      data: chat.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 14,
                          color: Store.isLightMode.value
                              ? Color(0xFF1E1F22)
                              : Color(0xFFEEEEEE),
                        ),
                        h1: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Store.isLightMode.value
                              ? Color(0xFF1E1F22)
                              : Color(0xFFEEEEEE),
                        ),
                        h2: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Store.isLightMode.value
                              ? Color(0xFF1E1F22)
                              : Color(0xFFEEEEEE),
                        ),
                        h3: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Store.isLightMode.value
                              ? Color(0xFF1E1F22)
                              : Color(0xFFEEEEEE),
                        ),
                        strong: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Store.isLightMode.value
                              ? Color(0xFF1E1F22)
                              : Color(0xFFEEEEEE),
                        ),
                        em: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Store.isLightMode.value
                              ? Color(0xFF1E1F22)
                              : Color(0xFFEEEEEE),
                        ),
                        code: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Store.isLightMode.value
                              ? Color(0xFF1E1F22)
                              : Color(0xFFE6EDF3),
                          backgroundColor: Colors.transparent,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Store.isLightMode.value
                              ? Color(0xFFF0F0F0)
                              : Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Store.isLightMode.value
                                ? Color(0xFFD0D7DE)
                                : Color(0xFF30363D),
                            width: 1,
                          ),
                        ),
                        codeblockPadding: EdgeInsets.all(16),
                        horizontalRuleDecoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Store.isLightMode.value
                                  ? Color(0xFFD0D0D0)
                                  : Color(0xFF4A4F5E),
                              width: 1.5,
                            ),
                          ),
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF10A37F),
                              width: 4,
                            ),
                          ),
                        ),
                        listBullet: TextStyle(
                          color: Store.isLightMode.value
                              ? Color(0xFF1E1F22)
                              : Color(0xFFEEEEEE),
                        ),
                      ),
                    ),
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
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/${chat.isMine ? 'user' : 'chat_gpt'}.png'),
                    fit: .cover,
                    onError: (_, e) => SizedBox(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Transform.translate(
                offset: Offset(0, -8),
                child: Text(
                  chat.isMine ? 'You' : 'Response',
                  style: TextStyle(
                    color: Store.isLightMode.value
                        ? Color(0xFF1E1F22)
                        : Color(0xFFEEEEEE),
                    fontSize: 15,
                    fontWeight: .w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _streamingIndicator() => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: List.generate(
          3,
          (i) => _Dot(delay: Duration(milliseconds: i * 200)),
        ),
      );

  Widget _chatMessageList() => SizedBox(
        height: double.infinity,
        child: _messages.isEmpty
            ? Center(
                child: Text(
                  Store.selectedSessionId.value.isEmpty
                      ? ''
                      : '대화를 시작해보세요.',
                  style: TextStyle(
                    color: Color(0xffA0A7BB),
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.separated(
                reverse: true,
                padding: .only(top: 60, bottom: 130, left: 30, right: 30),
                itemCount: _messages.length,
                scrollDirection: .vertical,
                separatorBuilder: (_, i) => SizedBox(height: 64),
                itemBuilder: (_, index) => Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    constraints: BoxConstraints(maxWidth: 950),
                    child: _messageItem(_messages[index]),
                  ),
                ),
              ),
      );
}

// 스트리밍 중 점 3개 애니메이션
class _Dot extends StatefulWidget {
  const _Dot({required this.delay});
  final Duration delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Color(0xFF10A37F),
            shape: BoxShape.circle,
          ),
        ),
      );
}
