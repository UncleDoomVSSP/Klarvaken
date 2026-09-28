#!/bin/bash
# Builds "Stay Awake.app" as a universal (Apple silicon + Intel) binary.
# Requires Xcode or the Xcode Command Line Tools on macOS.
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="Stay Awake"
EXECUTABLE="StayAwake"
MIN_MACOS="11.0"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
SOURCES=(Sources/StayAwake/*.swift)

rm -rf "$BUILD_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$BUILD_DIR/obj"

for arch in arm64 x86_64; do
    xcrun swiftc -O \
        -target "$arch-apple-macos$MIN_MACOS" \
        -framework AppKit -framework IOKit \
        -o "$BUILD_DIR/obj/$EXECUTABLE-$arch" \
        "${SOURCES[@]}"
done

lipo -create \
    "$BUILD_DIR/obj/$EXECUTABLE-arm64" \
    "$BUILD_DIR/obj/$EXECUTABLE-x86_64" \
    -output "$APP_DIR/Contents/MacOS/$EXECUTABLE"

cp Resources/Info.plist "$APP_DIR/Contents/Info.plist"

# Ad-hoc signature so the app runs locally without a developer certificate.
codesign --force --sign - "$APP_DIR"

(cd "$BUILD_DIR" && ditto -c -k --keepParent "$APP_NAME.app" "Stay_Awake.app.zip")

echo "Built $APP_DIR"
echo "Zipped $BUILD_DIR/Stay_Awake.app.zip"
