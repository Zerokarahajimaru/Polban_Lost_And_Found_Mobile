# Stage 1: Build
FROM dart:stable AS build

WORKDIR /app

# Install dart_frog_cli
RUN dart pub global activate dart_frog_cli

# Copy pubspec files
COPY pubspec.* ./
RUN dart pub get

# Copy seluruh kode backend
COPY . .

# Generate build production menggunakan dart_frog
RUN /root/.pub-cache/bin/dart_frog build

# Pindah ke hasil build
WORKDIR /app/build

# Get dependencies untuk hasil build
RUN dart pub get

# Compile menjadi executable
RUN dart compile exe bin/server.dart -o bin/server

# Stage 2: Runtime (Image yang lebih kecil)
FROM debian:bookworm-slim

# Install library yang dibutuhkan (SSL dll)
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/build/bin/server /app/bin/server

# Port default Dart Frog
EXPOSE 8080

# Jalankan server
CMD ["/app/bin/server"]
