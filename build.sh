#!/bin/bash
set -e

echo "=== Installing Flutter SDK ==="
git clone https://github.com/flutter/flutter.git -b stable --depth 1 .flutter

export PATH="$PATH:$(pwd)/.flutter/bin"

echo "=== Flutter version ==="
flutter --version

echo "=== Installing dependencies ==="
flutter pub get

echo "=== Building Flutter web ==="
flutter build web --release

echo "=== Build complete ==="
