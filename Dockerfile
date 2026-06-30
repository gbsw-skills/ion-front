# ---- Build stage: lean Flutter (web only, no Android SDK) ----
FROM debian:bookworm-slim AS build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends       git curl ca-certificates unzip xz-utils zip     && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $FLUTTER_HOME
ENV PATH=$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH
RUN git config --global --add safe.directory $FLUTTER_HOME     && flutter config --no-analytics     && flutter precache --web

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --base-href /

# ---- Serve stage: nginx ----
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
