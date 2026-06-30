/// 마크다운 텍스트에서 코드 블록/인라인 코드 바깥의 <br> 태그만 '\n\n'으로 변환한다.
String convertHtmlLineBreaks(String source) {
  // 펜스 코드블록(```...```) 또는 인라인 코드(`...`)를 통째로 매칭
  final codePattern = RegExp(r'```[\s\S]*?```|`[^`\n]+`', multiLine: true);
  final textParts = <String>[];
  final codeBlocks = <String>[];
  int lastEnd = 0;

  for (final match in codePattern.allMatches(source)) {
    textParts.add(source.substring(lastEnd, match.start));
    codeBlocks.add(match.group(0)!);
    lastEnd = match.end;
  }
  textParts.add(source.substring(lastEnd));

  final brPattern = RegExp(r'<br\s*/?>', caseSensitive: false);
  final result = StringBuffer();
  for (int i = 0; i < textParts.length; i++) {
    result.write(textParts[i].replaceAll(brPattern, '\n\n'));
    if (i < codeBlocks.length) result.write(codeBlocks[i]);
  }
  return result.toString();
}

/// 스트리밍 중인 마크다운을 렌더링하기 전 보정한다.
///
/// 누적된 원본 [source]는 변경하지 않고, 아직 닫히지 않은 코드펜스(```),
/// 인라인 코드(`), 굵게(**)에 임시로 닫는 짝을 붙인 새 문자열을 반환한다.
/// 코드펜스 안쪽 텍스트는 인라인 보정 대상에서 제외된다.
String healStreamingMarkdown(String source) {
  final fenceCount = RegExp(
    r'^ {0,3}```',
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
