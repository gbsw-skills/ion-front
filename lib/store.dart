import 'package:flutter/cupertino.dart';
import 'package:ion/models/chat_model.dart';
import 'package:ion/models/chat_room_model.dart';

class Store {
  static ValueNotifier<bool> isLightMode = ValueNotifier(true);
  static ValueNotifier<int> selectedChatIndex = ValueNotifier(0);
  static ValueNotifier<String> selectedSessionId = ValueNotifier('');
  static ValueNotifier<String> selectedSessionTitle = ValueNotifier('');
  // 값이 바뀔 때마다 채팅 목록을 다시 불러오라는 신호
  static ValueNotifier<int> chatListRefresh = ValueNotifier(0);
  static ValueNotifier<int> currentIndex = ValueNotifier(0);
  static String baseUrl = 'https://ion.gbsw.hs.kr/api/v1';
  static List<String> tabBarList = ['chat', 'filter', 'compass', 'settings'];
  static List<ChatRoomModel> chatList = [
    // Room 0: Flutter 상태관리 비교
    ChatRoomModel(
      title: "Flutter 상태관리 비교",
      chatList: [
        ChatModel(
          isMine: false,
          content: """결론적으로 **Riverpod**을 추천합니다.

특히 다음 상황에서 빛납니다:

- 중대형 프로젝트
- 테스트 코드를 작성하는 경우
- 컴파일 타임 안전성이 중요한 경우

**GetX**는 빠르게 프로토타입을 만들 때는 편리하지만, 프로젝트가 커질수록 유지보수가 어려워질 수 있어요.

처음 배우는 거라면 **Provider**로 개념을 잡고 Riverpod으로 넘어가는 게 자연스럽습니다.""",
        ),
        ChatModel(
          isMine: true,
          content: "그럼 어떤 걸 쓰는 게 좋을까요?",
        ),
        ChatModel(
          isMine: false,
          content: """Flutter 상태관리 라이브러리 비교입니다.

## Provider

- Flutter 공식 권장 (Google 지원)
- `InheritedWidget` 기반으로 동작
- 간단하지만 대규모 앱에서 한계

## Riverpod

- Provider의 단점을 개선한 차세대 라이브러리
- 컴파일 타임 안전성 보장
- 전역 접근 가능, 테스트 용이

```dart
final counterProvider = StateNotifierProvider<CounterNotifier, int>(
  (ref) => CounterNotifier(),
);

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  void increment() => state++;
}
```

## GetX

- 상태관리 + 라우팅 + DI 통합 패키지
- 보일러플레이트 최소화
- 대규모 프로젝트에서 유지보수 어려움

---

셋 다 사용 가능하지만 **Riverpod**이 가장 안정적입니다.""",
        ),
        ChatModel(
          isMine: true,
          content: "Flutter 상태관리 Riverpod, Provider, GetX 차이 알려줘",
        ),
      ],
    ),
    // Room 1: JWT 인증 구현
    ChatRoomModel(
      title: "JWT 인증 구현",
      chatList: [
        ChatModel(
          isMine: false,
          content: """리프레시 토큰 처리는 이렇게 합니다.

```python
@router.post("/refresh")
async def refresh_token(refresh_token: str):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=["HS256"])
        user_id = payload.get("sub")
        new_access = create_access_token({"sub": user_id})
        return {"access_token": new_access}
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
```

프론트엔드에서 `401` 응답을 받으면 자동으로 `/refresh`를 호출해서 새 토큰을 받아오면 됩니다.

Flutter에서는 `dio` 인터셉터로 처리하면 편해요:

```dart
dio.interceptors.add(InterceptorsWrapper(
  onError: (e, handler) async {
    if (e.response?.statusCode == 401) {
      await refreshToken();
      return handler.resolve(await dio.fetch(e.requestOptions));
    }
    return handler.next(e);
  },
));
```""",
        ),
        ChatModel(
          isMine: true,
          content: "리프레시 토큰은 어떻게 처리해요?",
        ),
        ChatModel(
          isMine: false,
          content: """FastAPI에서 JWT 인증을 구현하는 방법입니다.

## 패키지 설치

```bash
pip install python-jose[cryptography] passlib[bcrypt]
```

## 토큰 생성 함수

```python
from jose import JWTError, jwt
from datetime import datetime, timedelta

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"

def create_access_token(data: dict):
    expire = datetime.utcnow() + timedelta(minutes=30)
    data.update({"exp": expire})
    return jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)
```

## 로그인 엔드포인트

```python
@router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Incorrect credentials")
    token = create_access_token({"sub": user.username})
    return {"access_token": token, "token_type": "bearer"}
```

## 보호된 라우트

```python
async def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    username = payload.get("sub")
    return await get_user(username)

@router.get("/me")
async def read_me(user = Depends(get_current_user)):
    return user
```

---

모든 보호된 라우트에 `Depends(get_current_user)`를 추가하면 됩니다.""",
        ),
        ChatModel(
          isMine: true,
          content: "FastAPI에서 JWT 인증 구현 방법 알려줘",
        ),
      ],
    ),
    // Room 2: SQL 쿼리 최적화
    ChatRoomModel(
      title: "SQL 쿼리 최적화",
      chatList: [
        ChatModel(
          isMine: false,
          content: """이 쿼리에 복합 인덱스를 추가하면 됩니다.

```sql
CREATE INDEX idx_orders_user_status
ON orders(user_id, status, created_at DESC);
```

---

## 왜 이 인덱스인가

WHERE 절에서 `user_id`와 `status`를 필터링하고, ORDER BY에서 `created_at`을 사용하기 때문입니다.

인덱스 컬럼 순서는 **선택성 높은 순서**로 잡습니다:

- `user_id` — 사용자별 필터 (높은 선택성)
- `status` — 상태 필터
- `created_at` — 정렬용

## 적용 후 예상 결과

| 항목 | 이전 | 이후 |
|------|------|------|
| 실행 시간 | 2.3s | ~15ms |
| 스캔 방식 | Full Table Scan | Index Range Scan |
| 검토 행 수 | 1,200,000 | ~340 |""",
        ),
        ChatModel(
          isMine: true,
          content: "인덱스를 어디에 걸어야 해요?",
        ),
        ChatModel(
          isMine: false,
          content: """쿼리를 분석해봤습니다.

`EXPLAIN ANALYZE` 결과를 보면 `Seq Scan`이 나오고 있어요. 인덱스가 없어서 전체 테이블을 스캔하는 중입니다.

```sql
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE user_id = 42 AND status = 'pending'
ORDER BY created_at DESC;

-- 결과
Seq Scan on orders  (cost=0.00..24532.00 rows=12 width=84)
  Filter: ((user_id = 42) AND (status = 'pending'))
  Rows Removed by Filter: 1199988
Planning Time: 0.3ms
Execution Time: 2341.8ms
```

`user_id`, `status`, `created_at` 컬럼에 복합 인덱스가 필요합니다.""",
        ),
        ChatModel(
          isMine: true,
          content: "이 쿼리가 너무 느린데 왜 그런지 봐줘\n\n1백만 건 넘는 테이블인데 2초 넘게 걸려",
        ),
      ],
    ),
    // Room 3: Docker Compose 배포
    ChatRoomModel(
      title: "Docker Compose 배포 설정",
      chatList: [
        ChatModel(
          isMine: false,
          content: """PostgreSQL + Nginx 포함한 전체 `docker-compose.yml`입니다.

```yaml
version: '3.8'

services:
  api:
    build: .
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/appdb
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: appdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d appdb"]
      interval: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - api

volumes:
  postgres_data:
```

---

`Dockerfile`도 작성해드릴까요?""",
        ),
        ChatModel(
          isMine: true,
          content: "PostgreSQL이랑 Nginx도 같이 넣어줘",
        ),
        ChatModel(
          isMine: false,
          content: """FastAPI Docker 배포 기본 설정입니다.

## Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## docker-compose.yml

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DEBUG=false
    restart: unless-stopped
```

`docker compose up -d`로 실행하면 됩니다.""",
        ),
        ChatModel(
          isMine: true,
          content: "FastAPI Docker 배포 설정 해줘",
        ),
      ],
    ),
  ];
  static late String token;
  static late String refreshToken;
  static String userRole = '';
  static String displayName = '';
  static String username = '';
}
