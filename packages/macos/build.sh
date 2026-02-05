#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
APP_DIR="$BUILD_DIR/Clipclean.app"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 1. Bundle JS for JavaScriptCore (IIFE format, no Node/module deps)
echo "==> Bundling JavaScript..."
node "$SCRIPT_DIR/bundle-js.mjs" "$BUILD_DIR"

# 2. Create .app bundle structure
echo "==> Creating app bundle..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
cp "$SCRIPT_DIR/Info.plist" "$APP_DIR/Contents/"
cp "$BUILD_DIR/clipclean.bundle.js" "$APP_DIR/Contents/Resources/"

# 3. Compile Swift
echo "==> Compiling Swift..."
xcrun swiftc \
    -parse-as-library \
    -sdk "$(xcrun --show-sdk-path)" \
    -target arm64-apple-macos13.0 \
    -framework SwiftUI \
    -framework JavaScriptCore \
    -framework Carbon \
    -O \
    -o "$APP_DIR/Contents/MacOS/Clipclean" \
    "$SCRIPT_DIR"/Sources/*.swift

# 4. Ad-hoc code sign
echo "==> Signing..."
codesign --force --sign - "$APP_DIR"

echo ""
echo "Build complete: $APP_DIR"
echo ""
echo "To install:"
echo "  cp -r '$APP_DIR' /Applications/"
echo ""
echo "To run:"
echo "  open '$APP_DIR'"
