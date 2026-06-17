# 스트리밍 마크다운 보정(healing) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** SSE로 토큰 단위 스트리밍되는 AI 응답을 렌더링할 때, 코드펜스(```)·인라인 코드(`)·굵게(**)가 중간에 끊긴 상태로 인해 마크다운 렌더링이 깨지는 문제를 해결한다.

**Architecture:** 누적된 원본 텍스트는 그대로 보존하고, 렌더링 시점에만 순수 함수 `healStreamingMarkdown`으로 보정된 복사본을 만들어 `MarkdownBody`에 전달한다. 스트리밍 중인 메시지에만 보정을 적용하고, 완료된 메시지는 원본 그대로 렌더링한다. 토큰 수신 시 매번 `setState`하지 않고 로컬 버퍼에 모은 뒤 80ms 주기 `Timer`로만 화면을 갱신해 리빌드 빈도를 낮춘다.

**Tech Stack:** Flutter/Dart, `flutter_markdown_plus` (단종된 `flutter_markdown`의 유지보수 포크), `dart:async` `Timer`, `flutter_test`.

**설계 문서:** `docs/superpowers/specs/2026-06-17-streaming-markdown-healing-design.md`

---

## File Structure

- Create: `lib/utils/markdown_healing.dart` — 순수 함수 `healStreamingMarkdown(String source) -> String`. 외부 상태 없음, 다른 어떤 파일도 의존하지 않음.
- Create: `test/markdown_healing_test.dart` — 위 함수에 대한 유닛 테스트.
- Modify: `pubspec.yaml` — `flutter_markdown` → `flutter_markdown_plus` 의존성 교체.
- Modify: `lib/screens/chat_screen.dart` — import 교체, 렌더링 분기(`isLive`), `_sendChat`의 throttle 누적 로직.

---

## Task 1: `healStreamingMarkdown` 헬퍼 (TDD)

**Files:**
- Create: `lib/utils/markdown_healing.dart`
- Test: `test/markdown_healing_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/markdown_healing_test.dart` 파일을 다음 내용으로 만든다 (기존 `test/widget_test.dart`는 건드리지 않는다):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ion/utils/markdown_healing.dart';

void main() {
  group('healStreamingMarkdown', () {
    test('완전한 마크다운은 변경 없이 그대로 반환한다', () {
      const input =
          '안녕하세요 **굵게** 와 `code` 그리고\n```dart\nprint(1);\n```\n끝';
      expect(healStreamingMarkdown(input), input);
    });

    test('여는 코드펜스만 있고 닫는 펜스가 없으면 닫는 펜스를 추가한다', () {
      const input = '설명\n```dart\nvoid main() {';
      expect(healStreamingMarkdown(input), '$input\n```');
    });

    test('코드블록 밖 인라인 백틱이 홀수개면 백틱을 추가해 짝을 맞춘다', () {
      const input = '이건 `inline code 인데 안 닫힘';
      expect(healStreamingMarkdown(input), '$input`');
    });

    test('코드블록 밖 ** 가 홀수개면 ** 를 추가해 짝을 맞춘다', () {
      const input = '이건 **굵게 인데 안 닫힘';
      expect(healStreamingMarkdown(input), '$input**');
    });

    test('아직 닫히지 않은 코드블록 내부의 백틱/별표는 보정 대상에서 제외된다', () {
      const input = '```dart\nfinal s = "it`s a * test";';
      expect(healStreamingMarkdown(input), '$input\n```');
    });

    test('원본 문자열은 변경되지 않는다', () {
      const input = '```dart\ncode';
      final beforeCall = input;
      healStreamingMarkdown(input);
      expect(input, beforeCall);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행해서 실패 확인**

Run: `flutter test test/markdown_healing_test.dart`
Expected: FAIL — `lib/utils/markdown_healing.dart`가 없어서 `Error: Couldn't resolve the package 'ion'` 혹은 `Target of URI doesn't exist` 컴파일 에러가 난다.

- [ ] **Step 3: 최소 구현 작성**

`lib/utils/markdown_healing.dart`를 다음 내용으로 만든다:

```dart
/// 스트리밍 중인 마크다운을 렌더링하기 전 보정한다.
///
/// 누적된 원본 [source]는 변경하지 않고, 아직 닫히지 않은 코드펜스(```),
/// 인라인 코드(`), 굵게(**)에 임시로 닫는 짝을 붙인 새 문자열을 반환한다.
/// 코드펜스 안쪽 텍스트는 인라인 보정 대상에서 제외된다.
String healStreamingMarkdown(String source) {
  final fenceCount = RegExp(
    r'^```',
    multiLine: true,
  ).allMatches(source).length;

  var healed = fenceCount.isOdd ? '$source\n```' : source;

  final outsideFences = healed.replaceAll(RegExp(r'```[\s\S]*?```'), '');

  final backtickCount = outsideFences.split('`').length - 1;
  if (backtickCount.isOdd) healed = '$healed`';

  final boldCount = RegExp(r'\*\*').allMatches(outsideFences).length;
  if (boldCount.isOdd) healed = '$healed**';

  return healed;
}
```

- [ ] **Step 4: 테스트 실행해서 통과 확인**

Run: `flutter test test/markdown_healing_test.dart`
Expected: `00:0X +6: All tests passed!`

- [ ] **Step 5: 커밋**

```bash
git add lib/utils/markdown_healing.dart test/markdown_healing_test.dart
git commit -m "feat: 스트리밍 마크다운 보정 헬퍼 healStreamingMarkdown 추가"
```

---

## Task 2: `flutter_markdown` → `flutter_markdown_plus` 교체

**Files:**
- Modify: `pubspec.yaml:40`
- Modify: `lib/screens/chat_screen.dart:7`

- [ ] **Step 1: pubspec.yaml 의존성 교체**

`pubspec.yaml`의 40번째 줄:

```yaml
  flutter_markdown: ^0.7.7
```

을 다음으로 교체:

```yaml
  flutter_markdown_plus: ^1.0.7
```

- [ ] **Step 2: import 교체**

`lib/screens/chat_screen.dart`의 7번째 줄:

```dart
import 'package:flutter_markdown/flutter_markdown.dart';
```

을 다음으로 교체 (다른 줄과 알파벳 순서를 유지하려면 `flutter_markdown_plus`는 `flutter_highlight` 관련 import들 다음, `flutter_svg` 이전 자리에 와야 한다 — 즉 현재와 같은 위치):

```dart
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
```

- [ ] **Step 3: 의존성 설치**

Run: `flutter pub get`
Expected: `Got dependencies!` 출력, `pubspec.lock`에서 `flutter_markdown` 항목이 사라지고 `flutter_markdown_plus`가 추가됨.

- [ ] **Step 4: 정적 분석으로 API 호환성 확인**

Run: `flutter analyze lib/screens/chat_screen.dart`
Expected: `No issues found!` — `MarkdownBody`, `MarkdownStyleSheet`, `MarkdownElementBuilder`, `visitElementAfterWithContext`를 그대로 쓰고 있으므로 에러가 없어야 한다. 에러가 나면 `flutter_markdown_plus`의 실제 공개 API를 `flutter pub deps` 또는 `.dart_tool/package_config.json`이 가리키는 패키지 소스에서 확인하고 시그니처 차이를 메모해 다음 태스크 진행 전에 해결한다.

- [ ] **Step 5: 커밋**

```bash
git add pubspec.yaml pubspec.lock lib/screens/chat_screen.dart
git commit -m "build: 단종된 flutter_markdown을 flutter_markdown_plus로 교체"
```

---

## Task 3: 렌더링 분기 — 스트리밍 중인 말풍선만 보정 적용

**Files:**
- Modify: `lib/screens/chat_screen.dart` (import 추가, `_chatMessageList`의 `itemBuilder`, `_messageItem` 시그니처/본문)

- [ ] **Step 1: healing 헬퍼 import 추가**

`lib/screens/chat_screen.dart`의 로컬 import 블록 (현재 14-16번째 줄):

```dart
import '../models/chat_model.dart';
import '../store.dart';
import '../theme/app_colors.dart';
```

을 다음으로 교체:

```dart
import '../models/chat_model.dart';
import '../store.dart';
import '../theme/app_colors.dart';
import '../utils/markdown_healing.dart';
```

- [ ] **Step 2: `itemBuilder`에서 `isLive` 계산 후 전달**

`_chatMessageList()` 안의 `itemBuilder` (현재 494-500번째 줄):

```dart
                itemBuilder: (_, index) => Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    constraints: BoxConstraints(maxWidth: 950),
                    child: _messageItem(_messages[index]),
                  ),
                ),
```

을 다음으로 교체:

```dart
                itemBuilder: (_, index) {
                  final chat = _messages[index];
                  final isLive = index == 0 && !chat.isMine && _isStreaming;
                  return Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      constraints: BoxConstraints(maxWidth: 950),
                      child: _messageItem(chat, isLive: isLive),
                    ),
                  );
                },
```

- [ ] **Step 3: `_messageItem` 시그니처 변경 및 보정 적용**

`_messageItem` 선언부 (현재 342번째 줄):

```dart
  Widget _messageItem(ChatModel chat) {
```

을 다음으로 교체:

```dart
  Widget _messageItem(ChatModel chat, {required bool isLive}) {
```

`MarkdownBody`의 `data` 파라미터 (현재 357-358번째 줄):

```dart
              : MarkdownBody(
                  data: chat.content,
```

을 다음으로 교체:

```dart
              : MarkdownBody(
                  data: isLive ? healStreamingMarkdown(chat.content) : chat.content,
```

- [ ] **Step 4: 정적 분석**

Run: `flutter analyze lib/screens/chat_screen.dart`
Expected: `No issues found!` (호출부가 새 시그니처와 일치하는지 확인 — 이 파일 안에서 `_messageItem`을 호출하는 곳은 `itemBuilder` 한 곳뿐이다)

- [ ] **Step 5: 커밋**

```bash
git add lib/screens/chat_screen.dart
git commit -m "fix: 스트리밍 중인 말풍선에만 마크다운 보정을 적용"
```

---

## Task 4: 토큰 누적을 80ms 주기 throttle로 변경

**Files:**
- Modify: `lib/screens/chat_screen.dart:1` (import), `_sendChat` (현재 86-148번째 줄)

- [ ] **Step 1: `dart:async` import 추가**

`lib/screens/chat_screen.dart`의 1번째 줄 위에 추가 (dart: import는 package: import보다 위, 알파벳 순):

```dart
import 'dart:async';

import 'package:code_text_field/code_text_field.dart';
```

- [ ] **Step 2: AI 응답 자리 확보 이후 로직을 throttle 버퍼로 교체**

현재 `_sendChat` 안의 다음 블록 (AI 응답 자리 확보부터 `_isStreaming = false`까지, 현재 116-144번째 줄):

```dart
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
```

을 다음으로 교체:

```dart
    // AI 응답 자리 확보
    setState(() {
      _messages.insert(0, ChatModel(isMine: false, content: ''));
    });

    // 토큰은 로컬 버퍼에만 모으고, 80ms 주기로만 setState해 리빌드 빈도를 낮춘다.
    // (debounce는 토큰이 끊김 없이 연속 도착하는 동안 한 번도 flush되지 않을 수 있어
    //  고정 주기 throttle을 쓴다)
    var liveBuffer = '';
    final throttle = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted || liveBuffer == _messages[0].content) return;
      setState(() {
        _messages[0] = ChatModel(isMine: false, content: liveBuffer);
      });
    });

    // token 이벤트 누적, done 오면 종료
    try {
      await for (final token in stream) {
        if (!mounted) break;
        liveBuffer += token;
      }
    } catch (_) {
      if (liveBuffer.isEmpty) {
        liveBuffer = '⚠️ 응답을 받아오지 못했어요. 다시 시도해주세요.';
      }
    } finally {
      throttle.cancel();
    }

    if (!mounted) return;
    setState(() {
      _messages[0] = ChatModel(isMine: false, content: liveBuffer);
      _isStreaming = false;
    });
```

이 변경으로 마지막 throttle tick 이후 도착한 토큰도 스트림 종료 시 마지막 `setState`에서 빠짐없이 반영되고, 위젯이 dispose된 경우에는 `await for` 루프를 `break`로 빠져나와 구독을 정리한 뒤 더 이상 `setState`를 호출하지 않는다.

- [ ] **Step 3: 정적 분석**

Run: `flutter analyze lib/screens/chat_screen.dart`
Expected: `No issues found!`

- [ ] **Step 4: 커밋**

```bash
git add lib/screens/chat_screen.dart
git commit -m "perf: AI 응답 스트리밍 토큰 누적을 80ms 주기 throttle로 변경"
```

---

## Task 5: 전체 검증

**Files:** 없음 (검증만 수행)

- [ ] **Step 1: 전체 정적 분석**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: 전체 테스트 실행**

Run: `flutter test`
Expected: `markdown_healing_test.dart`의 6개 테스트 포함 전체 통과. (`test/widget_test.dart`는 전체가 주석 처리되어 있어 실행할 테스트가 없다는 메시지만 나오는 것이 정상)

- [ ] **Step 3: 수동 동작 확인**

앱을 실행해 채팅방에서 AI에게 "다트로 hello world 코드 보여줘"처럼 코드블록이 포함된 답을 받아본다. 스트리밍 도중 코드블록 헤더(언어명 + 복사 버튼)가 깨지지 않고 바로 나타나는지, 스트리밍이 끝난 후에도 코드블록과 복사 버튼이 정상 동작하는지 확인한다. (Flutter 앱이라 `run` 스킬로 디바이스/웹에서 직접 실행해 확인하는 것을 권장)

- [ ] **Step 4: 최종 커밋 여부 확인**

Run: `git status`
Expected: `lib/utils/markdown_healing.dart`, `test/markdown_healing_test.dart`, `pubspec.yaml`, `pubspec.lock`, `lib/screens/chat_screen.dart` 변경이 모두 이전 태스크들에서 커밋되어 있어 untracked/unstaged 변경이 없어야 한다 (Task 시작 전부터 있던 `pubspec.lock`의 무관한 transitive 의존성 변경은 Task 2에서 같이 커밋되어 자연스럽게 해소된다).
