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
