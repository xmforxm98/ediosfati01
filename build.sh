#!/bin/bash

# Flutter 웹 빌드 스크립트
echo "Building Flutter web app..."

# Flutter 의존성 설치
flutter pub get

# 웹 빌드 실행
flutter build web --release

echo "Build completed!"
echo "Build output is in: build/web/" 