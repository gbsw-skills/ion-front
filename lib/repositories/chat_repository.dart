import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ion/models/chat_model.dart';
import 'package:ion/models/chat_session_model.dart';
import 'package:ion/store.dart';

void _log(String msg) => debugPrint('[CHAT] $msg');

class ChatRepository {
  /// POST /chat/sessions — 새 채팅 세션 생성
  Future<ChatSession?> createSession() async {
    final url = Uri.parse('${Store.baseUrl}/chat/sessions');
    _log('POST $url');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    _log('POST $url → ${response.statusCode}');
    if (response.body.isNotEmpty) _log('body: ${response.body}');

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return ChatSession.fromJson(body['data']);
    }
    return null;
  }

  /// GET /chat/sessions — 세션 목록 조회
  Future<List<ChatSession>> getSessions({int page = 0, int size = 20}) async {
    final uri = Uri.parse(
      '${Store.baseUrl}/chat/sessions',
    ).replace(queryParameters: {'page': '$page', 'size': '$size'});
    _log('GET $uri');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    _log('GET $uri → ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['data']['content'] as List;
      _log('sessions count: ${content.length}');
      return content.map((e) => ChatSession.fromJson(e)).toList();
    }
    _log('getSessions failed: ${response.body}');
    return [];
  }

  /// GET /chat/sessions/{sessionId}/messages — 메시지 내역 조회
  Future<List<ChatModel>> getMessages(String sessionId) async {
    final uri = Uri.parse(
      '${Store.baseUrl}/chat/sessions/$sessionId/messages',
    ).replace(queryParameters: {'page': '0', 'size': '50'});
    _log('GET $uri');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    _log('GET $uri → ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['data']['content'] as List;
      _log('messages count: ${content.length}');
      return content
          .map(
            (e) => ChatModel(
              isMine: e['role'] == 'user',
              content: (e['content'] as String?) ?? '',
            ),
          )
          .toList();
    }
    _log('getMessages failed: ${response.body}');
    return [];
  }

  /// DELETE /chat/sessions/{sessionId} — 세션 삭제
  Future<bool> deleteSession(String sessionId) async {
    final url = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId');
    _log('DELETE $url');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer ${Store.token}'},
    );
    _log('DELETE $url → ${response.statusCode}');
    if (response.body.isNotEmpty) _log('body: ${response.body}');
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// POST /chat/sessions/{sessionId}/messages — 질의 전송 (202 Accepted)
  Future<bool> sendMessage(String sessionId, String content) async {
    final url = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId/messages');
    _log(
      'POST $url  content="${content.length > 50 ? '${content.substring(0, 50)}...' : content}"',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Store.token}',
      },
      body: jsonEncode({'content': content}),
    );
    _log('POST $url → ${response.statusCode}');
    if (response.body.isNotEmpty) _log('body: ${response.body}');
    return response.statusCode == 202;
  }

  /// GET /chat/sessions/{sessionId}/stream — SSE 스트리밍 수신
  ///
  /// 연결 응답(헤더)을 받은 뒤에 토큰 스트림을 반환하므로,
  /// 호출자는 반환된 Future가 완료된 시점에 SSE 연결이 열려 있음을 보장받는다.
  /// `token` 이벤트는 토큰 문자열로, `done`/`error` 이벤트 수신 시 스트림이 종료된다.
  Future<Stream<String>> streamResponse(String sessionId) async {
    final uri = Uri.parse('${Store.baseUrl}/chat/sessions/$sessionId/stream');
    _log('SSE CONNECT $uri');
    final client = http.Client();
    final request = http.Request('GET', uri);
    request.headers['Authorization'] = 'Bearer ${Store.token}';
    request.headers['Accept'] = 'text/event-stream';
    final streamed = await client.send(request);
    _log('SSE → ${streamed.statusCode}');

    final controller = StreamController<String>();

    () async {
      String eventType = '';
      final buffer = StringBuffer();
      var finished = false;
      Timer? forceCloseTimer;

      void finish() {
        if (finished) return;
        finished = true;
        controller.close();
        // 서버가 응답을 정상적으로 끝맺지 못하는 경우를 대비한 안전장치
        forceCloseTimer = Timer(Duration(seconds: 5), () {
          _log('SSE force close (server did not close in time)');
          client.close();
        });
      }

      try {
        await for (final line
            in streamed.stream
                .transform(utf8.decoder)
                .transform(LineSplitter())) {
          if (line.isNotEmpty && !(line.startsWith('data:') && eventType == 'token')) {
            _log('SSE raw: "$line"');
          }
          if (line.startsWith('event:')) {
            eventType = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            final data = line.substring(5).trim();
            if (eventType == 'token') {
              if (finished) continue;
              final json = jsonDecode(data);
              final token = json['token'] as String;
              buffer.write(token);
              controller.add(token);
            } else if (eventType == 'title') {
              _log('SSE title raw: $data');
              final json = jsonDecode(data);
              final title = json['title'] as String;
              _log('SSE title: $title');
              Store.selectedSessionTitle.value = title;
              Store.chatListRefresh.value++;
            } else if (eventType == 'done') {
              _log('SSE done data: $data — total: "${buffer.toString().length}" chars');
              finish();
            } else if (eventType == 'error') {
              _log('SSE error: $data');
              if (!finished) controller.addError(Exception('SSE error: $data'));
              finish();
            }
          }
        }
        // 서버가 chunked 응답을 정상적으로 끝맺음 (마지막 종료 청크까지 수신)
        _log('SSE stream closed by server');
      } catch (e) {
        _log('SSE exception: $e');
        if (!finished) controller.addError(e);
      } finally {
        forceCloseTimer?.cancel();
        if (!finished) await controller.close();
        client.close();
        _log('SSE client closed');
      }
    }();

    return controller.stream;
  }
}
