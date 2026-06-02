#!/bin/bash
set -e

echo "==> Baixando Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter

export PATH="$PATH:`pwd`/_flutter/bin"

echo "==> Versao do Flutter:"
flutter --version

echo "==> Habilitando Flutter Web..."
flutter config --enable-web

echo "==> Baixando dependencias..."
flutter pub get

echo "==> Buildando para Web (release)..."
flutter build web --release

echo "==> Build concluido em build/web"
