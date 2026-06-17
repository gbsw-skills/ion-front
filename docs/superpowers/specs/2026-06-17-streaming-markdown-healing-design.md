# 스트리밍 마크다운 보정(healing) 설계

## 배경 / 문제

`lib/screens/chat_screen.dart`에서 AI 응답을 SSE로 토큰 단위 수신하여 `_messages[0].content`에 누적하고, `MarkdownBody`로 즉시 렌더링한다. 스트리밍 도중 여는 코드펜스(` ``` `)만 도착하고 닫는 펜스가 아직 오지 않은 중간 상태가 발생하면, 마크다운 파서가 미완성 문법으로 인식해 렌더링이 깨진다. 인라인 코드(백틱 1개)나 굵게(`**`)가 끊긴 경우도 동일한 문제가 생길 수 있다.

부수적으로:
- `pubspec.yaml`이 단종된 `flutter_markdown: ^0.7.7`을 사용 중 — 유지보수되는 포크 `flutter_markdown_plus`로 교체 필요.
- 토큰마다 `setState`를 호출해 매 토큰마다 리빌드가 발생 — 스트리밍 중 성능 저하.

## 범위

- `lib/screens/chat_screen.dart`의 스트리밍 누적/렌더링 로직
- 신규 순수 함수 헬퍼 (`lib/utils/markdown_healing.dart`)
- `pubspec.yaml` 의존성 교체
- 헬퍼 함수에 대한 유닛 테스트

다른 화면, 채팅 기록 조회(`_loadMessages`), `chat_repository.dart`의 SSE 파싱 로직은 변경하지 않는다 (이미 정상 동작).

## 설계

### 1. 패키지 교체

`pubspec.yaml`: `flutter_markdown: ^0.7.7` 제거, `flutter_markdown_plus: ^1.0.7` 추가.
`chat_screen.dart` import: `package:flutter_markdown/flutter_markdown.dart` → `package:flutter_markdown_plus/flutter_markdown_plus.dart`.

`flutter_markdown_plus`는 단종된 `flutter_markdown`을 그대로 이어받은 포크로 `MarkdownBody`, `MarkdownStyleSheet`, `MarkdownElementBuilder`, `visitElementAfterWithContext` API가 동일하다. 코드베이스 전체에서 `flutter_markdown`을 사용하는 곳은 `chat_screen.dart` 한 곳뿐이므로 import 교체 외 추가 코드 변경은 불필요하다.

### 2. 마크다운 보정 헬퍼 — `lib/utils/markdown_healing.dart`

순수 함수 `String healStreamingMarkdown(String source)`. 입력 문자열을 변경하지 않고, 보정된 새 문자열을 반환한다.

알고리즘:
1. `source`에서 줄 시작 ` ``` ` 개수를 센다 (`RegExp(r'^```', multiLine: true)`).
2. 개수가 홀수면 (코드블록이 안 닫힘) `healed = source + '\n```'`. 짝수면 `healed = source`.
3. `healed`에서 짝이 맞는 ` ``` ... ``` ` 블록을 전부 제거해 "펜스 밖 텍스트"를 만든다. 2번에서 펜스 개수를 짝수로 맞췄으므로 안전하게 페어 단위로 제거할 수 있다.
4. "펜스 밖 텍스트"에서 단독 백틱(`` ` ``) 개수가 홀수면 `healed` 끝에 `` ` `` 하나를 추가한다.
5. "펜스 밖 텍스트"에서 `**` 개수가 홀수면 `healed` 끝에 `**`를 추가한다.
6. `healed`를 반환한다.

3번 단계에서 코드블록 내부 텍스트를 인라인 분석 대상에서 제외하므로, 코드 안에 우연히 들어있는 백틱·별표는 보정 로직에 영향을 주지 않는다.

### 3. 스트리밍 누적 — throttle (주기 80ms)

현재 `_sendChat()`은 토큰마다 `setState`를 호출한다 (`chat_screen.dart:122-131`). 이를 다음으로 변경한다:

- 토큰 수신 루프 안에서는 로컬 변수 `String liveBuffer`에만 문자열을 이어붙인다 (리빌드 없음).
- 스트리밍 시작 시 `Timer.periodic(Duration(milliseconds: 80), ...)`를 시작한다. 매 tick마다 `liveBuffer`가 현재 화면에 표시된 내용과 다르면 그 시점에만 `setState`로 `_messages[0]`을 갱신한다.
- 스트림이 끝나면(정상 종료/에러 모두) 타이머를 취소하고, 마지막 `liveBuffer` 전체를 한 번 더 `setState`로 반영한 뒤 `_isStreaming = false`로 전환한다 (마지막 tick 이후 도착한 토큰이 누락되지 않도록).

**throttle을 선택한 이유 (debounce 대신):** 토큰이 끊김 없이 연속으로 도착하는 구간에서 debounce(토큰마다 타이머 리셋)는 스트림이 잠시 멈출 때까지 한 번도 flush되지 않을 수 있다. 고정 주기 throttle은 토큰 도착 패턴과 무관하게 항상 일정한 간격으로 화면을 갱신한다. 별도 패키지(rxdart 등)는 추가하지 않고 기존 `dart:async`의 `Timer`만 사용한다.

### 4. 렌더링 분기 — 스트리밍 중 vs 완료

`_chatMessageList()`의 `itemBuilder`에서 다음을 계산해 `_messageItem`에 전달한다:

```dart
final isLive = index == 0 && !chat.isMine && _isStreaming;
```

`_messageItem(ChatModel chat, {required bool isLive})`에서:

```dart
MarkdownBody(
  data: isLive ? healStreamingMarkdown(chat.content) : chat.content,
  ...
)
```

`chat.content` (누적 원본)는 어떤 경우에도 수정하지 않는다. `isLive`가 `false`인 모든 메시지(스트리밍 완료된 메시지, 과거 메시지, 사용자 메시지)는 보정 없이 원본 그대로 렌더링된다.

### 5. 테스트

`test/markdown_healing_test.dart`에 `healStreamingMarkdown` 유닛 테스트 추가:
- 완전한 마크다운(짝이 맞음) → 변경 없이 그대로 반환
- 여는 코드펜스만 있고 닫는 펜스 없음 → 닫는 펜스가 추가됨
- 코드블록 밖 인라인 백틱 1개(홀수) → 백틱 추가되어 짝 맞춰짐
- 코드블록 밖 `**` 홀수개 → `**` 추가되어 짝 맞춰짐
- 아직 닫히지 않은 코드블록 *내부*에 백틱이나 `*`가 있어도 인라인 보정이 적용되지 않음 (코드 내용 그대로 보존)
- 원본 입력 문자열 객체가 함수 호출로 인해 변경되지 않음 (참조 비교 또는 별도 변수로 원본 보존 확인)

## 영향받지 않는 부분

- `_CodeBlockBuilder`, `_CodeBlock` 위젯, 구문 강조(`flutter_highlight`) 로직은 변경 없음.
- `chat_repository.dart`의 SSE 파싱/버퍼링 로직은 변경 없음.
- 과거 메시지 로딩(`_loadMessages`)이나 사용자 메시지 렌더링은 영향받지 않음 (`isLive`가 항상 `false`).
