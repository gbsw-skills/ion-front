enum RequestCode {
  SUCCESS,
  FAIL,
  AUTH_001,
  AUTH_002,
  AUTH_003,
  CHAT_001,
  CHAT_002,
  CHAT_003,
  NOTICE_001,
  DOCUMENT_001,
  DOCUMENT_002,
  DOCUMENT_003,
  LLM_001,
  LLM_002,
  COMMON_001,
  COMMON_002;

  static RequestCode fromCode(String code) {
    switch (code) {
      case 'AUTH_001':
        return RequestCode.AUTH_001;
      case 'AUTH_002':
        return RequestCode.AUTH_002;
      case 'AUTH_003':
        return RequestCode.AUTH_003;
      case 'CHAT_001':
        return RequestCode.CHAT_001;
      case 'CHAT_002':
        return RequestCode.CHAT_002;
      case 'CHAT_003':
        return RequestCode.CHAT_003;
      case 'NOTICE_001':
        return RequestCode.NOTICE_001;
      case 'DOCUMENT_001':
        return RequestCode.DOCUMENT_001;
      case 'DOCUMENT_002':
        return RequestCode.DOCUMENT_002;
      case 'DOCUMENT_003':
        return RequestCode.DOCUMENT_003;
      case 'LLM_001':
        return RequestCode.LLM_001;
      case 'LLM_002':
        return RequestCode.LLM_002;
      case 'COMMON_001':
        return RequestCode.COMMON_001;
      case 'COMMON_002':
        return RequestCode.COMMON_002;
      case 'success':
        return RequestCode.SUCCESS;
      default: return FAIL;
    }
  }
}

extension HistoryTapExtension on RequestCode {
  String get message {
    switch (this) {
      case RequestCode.AUTH_001:
        return '인증 토큰 없음 또는 만료';
      case RequestCode.AUTH_002:
        return '아이디 또는 비밀번호 불일치';
      case RequestCode.AUTH_003:
        return '해당 리소스에 대한 권한 없음';
      case RequestCode.CHAT_001:
        return '채팅 세션을 찾을 수 없음';
      case RequestCode.CHAT_002:
        return '메시지 내용이 비어 있음S';
      case RequestCode.CHAT_003:
        return '채팅 메시지를 찾을 수 없음';
      case RequestCode.NOTICE_001:
        return '공지사항을 찾을 수 없음';
      case RequestCode.DOCUMENT_001:
        return '문서를 찾을 수 없음';
      case RequestCode.DOCUMENT_002:
        return '지원하지 않는 파일 형식';
      case RequestCode.DOCUMENT_003:
        return '파일 크기 초과 (50MB 제한)';
      case RequestCode.LLM_001:
        return 'LLM 서버 연결 실패';
      case RequestCode.LLM_002:
        return 'LLM 응답 타임아웃';
      case RequestCode.COMMON_001:
        return '서버 내부 오류';
      case RequestCode.COMMON_002:
        return '요청 유효성 검사 실패 (필수 필드 누락 등)';
      case RequestCode.SUCCESS:
        return '성공';
      case RequestCode.FAIL:
        return '실패';
    }
  }
  String get code {
    switch (this) {
      case RequestCode.AUTH_001:
        return '401';
      case RequestCode.AUTH_002:
        return '401';
      case RequestCode.AUTH_003:
        return '403';
      case RequestCode.CHAT_001:
        return '404';
      case RequestCode.CHAT_002:
        return '400';
      case RequestCode.CHAT_003:
        return '404';
      case RequestCode.NOTICE_001:
        return '404';
      case RequestCode.DOCUMENT_001:
        return '404';
      case RequestCode.DOCUMENT_002:
        return '400';
      case RequestCode.DOCUMENT_003:
        return '413';
      case RequestCode.LLM_001:
        return '503';
      case RequestCode.LLM_002:
        return '504';
      case RequestCode.COMMON_001:
        return '500';
      case RequestCode.COMMON_002:
        return '400';
      case RequestCode.SUCCESS:
        return '200';
      case RequestCode.FAIL:
        return '실패';
    }
  }
}