import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:highlight/highlight.dart' show highlight;
import 'package:highlight/languages/all.dart' show allLanguages;
import 'package:ion/repositories/chat_repository.dart';
import 'package:markdown/markdown.dart' as md;

import '../models/chat_model.dart';
import '../store.dart';
import '../theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final CodeController _chatController = CodeController();
  final _repo = ChatRepository();

  List<ChatModel> _messages = [];
  bool _isStreaming = false;
  bool _isCodeInput = false;

  @override
  void initState() {
    super.initState();
    Store.selectedSessionId.addListener(_onSessionChanged);
    Store.isLightMode.addListener(_rebuild);
    _chatController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    Store.selectedSessionId.removeListener(_onSessionChanged);
    Store.isLightMode.removeListener(_rebuild);
    _chatController.removeListener(_onInputChanged);
    _chatController.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  // 여러 줄(코드 붙여넣기 등) 입력 시 코드 에디터 형태로 전환하고 언어를 자동 감지
  void _onInputChanged() {
    final text = _chatController.text;
    final isCode = text.contains('\n');
    if (isCode == _isCodeInput) return;

    if (isCode) {
      final detected = highlight.parse(text, autoDetection: true).language;
      _chatController.language = allLanguages[detected];
    } else {
      _chatController.language = null;
    }
    setState(() => _isCodeInput = isCode);
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

    // SSE 연결과 메시지 전송을 동시에 시작
    // (SSE를 먼저 connect만 하고 응답을 기다리면, 진행 중인 응답이 없는 세션에서는
    //  서버가 헤더를 플러시하지 않아 무한 대기하므로 두 요청을 동시에 보낸다)
    final streamFuture = _repo.streamResponse(sessionId);
    final sentFuture = _repo.sendMessage(sessionId, content);

    final stream = await streamFuture;
    if (!mounted) return;

    final sent = await sentFuture;
    if (!mounted) return;
    if (!sent) {
      setState(() => _isStreaming = false);
      return;
    }

    // AI 응답 자리 확보
    setState(() {
      _messages.insert(0, ChatModel(isMine: false, content: ''));
    });

    // token 이벤트 누적, done 오면 종료
    try {
      await for (final token in stream) {
        if (!mounted) return;
        setState(() {
          _messages[0] = ChatModel(
            isMine: false,
            content: _messages[0].content + token,
          );
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_messages[0].content.isEmpty) {
          _messages[0] = ChatModel(
            isMine: false,
            content: '⚠️ 응답을 받아오지 못했어요. 다시 시도해주세요.',
          );
        }
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
                padding: EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 27,
                ),
                child: Text(
                  title.isEmpty ? '채팅방을 선택해주세요' : title,
                  style: TextStyle(
                    fontSize: 22,
                    color: AppColors.textPrimary,
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
                color: AppColors.cardBackground,
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
    final backgroundColor = AppColors.surfaceBackground;
    final canSend = Store.selectedSessionId.value.isNotEmpty && !_isStreaming;

    return Align(
      alignment: .bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 44, horizontal: 14),
        child: Container(
          constraints: BoxConstraints(maxWidth: 980),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(minHeight: 55, maxHeight: 500),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: .circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.inputShadow,
                        blurRadius: 29,
                        offset: Offset(0, 19),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: .center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.iconBoxBackground,
                          borderRadius: .circular(8),
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          child: Focus(
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.enter &&
                                  !HardwareKeyboard.instance.isShiftPressed) {
                                if (canSend) _sendChat(_chatController.text);
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
                            child: _buildEditor(canSend),
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
                                    Color(0xffA0A7BB),
                                    BlendMode.srcIn,
                                  ),
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

  // 일반 입력은 TextField, 여러 줄(코드) 입력은 코드 에디터(CodeField)로 표시
  Widget _buildEditor(bool canSend) {
    final isLight = Store.isLightMode.value;
    final textColor = AppColors.textPrimary;

    if (!_isCodeInput) {
      return TextField(
        controller: _chatController,
        enabled: canSend,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        minLines: 1,
        maxLines: 8,
        keyboardType: TextInputType.multiline,
        style: TextStyle(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          contentPadding: .symmetric(horizontal: 14, vertical: 14),
          hintText: canSend
              ? 'Ask questions, or type \'/\' for commands'
              : '채팅방을 선택해주세요',
          hintStyle: TextStyle(color: Color(0xffA0A7BB)),
          border: .none,
        ),
      );
    }

    return CodeTheme(
      data: CodeThemeData(styles: isLight ? githubTheme : atomOneDarkTheme),
      child: CodeField(
        controller: _chatController,
        enabled: canSend,
        textStyle: TextStyle(
          fontSize: 13,
          fontFamily: 'monospace',
          height: 1.4,
          color: textColor,
        ),
        minLines: 1,
        maxLines: 20,
        lineNumbers: false,
        background: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _messageItem(ChatModel chat) {
    final bubbleColor = chat.isMine
        ? AppColors.chatBubbleMine
        : AppColors.chatBubbleOther;

    return Stack(
      children: [
        Container(
          padding: .symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: .circular(10),
          ),
          child: chat.content.isEmpty
              ? _streamingIndicator()
              : MarkdownBody(
                  data: chat.content,
                  builders: {
                    'pre': _CodeBlockBuilder(
                      isLight: Store.isLightMode.value,
                    ),
                  },
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    h1: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    h2: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    h3: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    strong: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    em: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textPrimary,
                    ),
                    code: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: AppColors.codeInlineText,
                      backgroundColor: Colors.transparent,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    codeblockPadding: EdgeInsets.zero,
                    horizontalRuleDecoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                    ),
                    blockquoteDecoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppColors.accent,
                          width: 4,
                        ),
                      ),
                    ),
                    listBullet: TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
        ),
        SelectionContainer.disabled(
          child: Transform.translate(
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
                        'assets/images/${chat.isMine ? 'user' : 'chat_gpt'}.png',
                      ),
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
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: .w800,
                    ),
                  ),
                ),
              ],
            ),
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
              Store.selectedSessionId.value.isEmpty ? '' : '대화를 시작해보세요.',
              style: TextStyle(
                color: Color(0xffA0A7BB),
                fontSize: 14,
              ),
            ),
          )
        : DefaultSelectionStyle(
            selectionColor: Color(0xff10A37F).withValues(alpha: 0.35),
            child: SelectionArea(
              child: ListView.separated(
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
            ),
          ),
  );
}

// 스트리밍 중 점 3개 애니메이션
class _Dot extends StatefulWidget {
  _Dot({required this.delay});
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
      duration: Duration(milliseconds: 600),
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

// 마크다운의 코드 블록(```)을 Claude 스타일의 헤더 + 복사 버튼이 있는 위젯으로 변환
class _CodeBlockBuilder extends MarkdownElementBuilder {
  _CodeBlockBuilder({required this.isLight});

  final bool isLight;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    md.Element? codeElement;
    for (final child in element.children ?? <md.Node>[]) {
      if (child is md.Element && child.tag == 'code') {
        codeElement = child;
        break;
      }
    }

    final code = (codeElement ?? element).textContent;
    final className = codeElement?.attributes['class'] ?? '';
    final language = className.startsWith('language-')
        ? className.substring('language-'.length)
        : null;

    return _CodeBlock(
      code: code.replaceAll(RegExp(r'\n$'), ''),
      language: language,
      isLight: isLight,
    );
  }
}

// Claude 스타일 코드 블록: 언어 표시 + 복사 버튼 + 구문 강조
class _CodeBlock extends StatefulWidget {
  _CodeBlock({
    required this.code,
    required this.language,
    required this.isLight,
  });

  final String code;
  final String? language;
  final bool isLight;

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = widget.isLight ? Color(0xFFE7E9F0) : Color(0xFF20242C);
    final bodyColor = widget.isLight ? Color(0xFFF6F8FA) : Color(0xFF161B22);
    final borderColor = widget.isLight ? Color(0xFFD0D7DE) : Color(0xFF30363D);
    final labelColor = widget.isLight ? Color(0xFF57606A) : Color(0xFF8B949E);

    final baseTheme = widget.isLight ? githubTheme : atomOneDarkTheme;
    final codeTheme = Map<String, TextStyle>.from(baseTheme);
    codeTheme['root'] = (codeTheme['root'] ?? TextStyle()).copyWith(
      backgroundColor: Colors.transparent,
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bodyColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: headerColor,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (widget.language?.isNotEmpty ?? false)
                      ? widget.language!
                      : 'text',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: labelColor,
                  ),
                ),
                InkWell(
                  onTap: _copy,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Icon(
                          _copied ? Icons.check : Icons.copy_outlined,
                          size: 14,
                          color: labelColor,
                        ),
                        Text(
                          _copied ? '복사됨' : '복사',
                          style: TextStyle(fontSize: 12, color: labelColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(14),
            child: HighlightView(
              widget.code,
              language: widget.language ?? 'plaintext',
              theme: codeTheme,
              textStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
