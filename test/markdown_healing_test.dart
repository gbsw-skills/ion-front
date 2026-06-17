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
