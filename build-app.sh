#!/usr/bin/env bash
# Builds Prompty and wraps it in a double-clickable Prompty.app bundle.
set -euo pipefail

cd "$(dirname "$0")"

swift build -c release

APP="build/Prompty.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/Prompty" "$APP/Contents/MacOS/Prompty"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Prompty</string>
    <key>CFBundleDisplayName</key>
    <string>Prompty</string>
    <key>CFBundleIdentifier</key>
    <string>com.simeongriggs.prompty</string>
    <key>CFBundleExecutable</key>
    <string>Prompty</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP" >/dev/null
echo "Built $APP"
