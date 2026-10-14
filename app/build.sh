#!/bin/bash
set -e

# Clone Flutter if not already cached
if [ ! -d "$HOME/_flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/_flutter"
fi

export PATH="$PATH:$HOME/_flutter/bin"
flutter --version

echo "Building Flutter Web..."
flutter pub get
flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL:-https://fieldnotes-api.onrender.com}"
