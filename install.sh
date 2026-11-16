#!/bin/zsh
# Build WinterIsComing, install it as a .app, and start it at login.
# Usage: zsh install.sh [--system] [--no-login] [--keep-alive] [--uninstall]

set -euo pipefail

APP_NAME="WinterIsComing"
LABEL="com.yike-shi.winteriscoming"
VERSION="1.0.0"
ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT/.build"
APP="$BUILD_DIR/$APP_NAME.app"
AGENT_DIR="$HOME/Library/LaunchAgents"
AGENT="$AGENT_DIR/$LABEL.plist"
UID_NUM="$(id -u)"

SYSTEM=0
LOGIN=1
KEEP_ALIVE=0
UNINSTALL=0

usage() {
    cat <<EOF
Usage: zsh install.sh [options]

  (no options)   Build and install to ~/Applications, start at login
  --system       Install to /Applications instead (may ask for sudo)
  --no-login     Do not start WinterIsComing at login
  --keep-alive   Relaunch even after a normal quit (not just after a crash)
  --uninstall    Remove the app, login item, and saved settings
  -h, --help     Show this help
EOF
}

for arg in "$@"; do
    case "$arg" in
        --system) SYSTEM=1 ;;
        --no-login) LOGIN=0 ;;
        --keep-alive) KEEP_ALIVE=1 ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage; exit 1 ;;
    esac
done

run_privileged() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

remove_app() {
    local dest="$1"
    [[ -e "$dest" ]] || return 0
    if [[ -w "$(dirname "$dest")" ]]; then
        rm -rf "$dest"
    else
        run_privileged rm -rf "$dest"
    fi
}

stop_agent() {
    launchctl bootout "gui/$UID_NUM/$LABEL" 2>/dev/null || true
    launchctl remove "$LABEL" 2>/dev/null || true
}

if (( UNINSTALL )); then
    stop_agent
    rm -f "$AGENT"
    remove_app "$HOME/Applications/$APP_NAME.app"
    remove_app "/Applications/$APP_NAME.app"
    defaults delete "$LABEL" 2>/dev/null || true
    pkill -x "$APP_NAME" 2>/dev/null || true
    echo "WinterIsComing removed."
    exit 0
fi

if ! command -v swiftc >/dev/null 2>&1; then
    echo "swiftc not found. Install the Xcode Command Line Tools first:" >&2
    echo "  xcode-select --install" >&2
    exit 1
fi

echo "Building $APP_NAME..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O "$ROOT/$APP_NAME.swift" -o "$APP/Contents/MacOS/$APP_NAME"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$LABEL</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
PLIST

xattr -cr "$APP"
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true

if (( SYSTEM )); then
    DEST="/Applications/$APP_NAME.app"
    if [[ -w /Applications ]]; then
        rm -rf "$DEST"
        ditto "$APP" "$DEST"
    else
        run_privileged rm -rf "$DEST"
        run_privileged ditto "$APP" "$DEST"
    fi
else
    DEST="$HOME/Applications/$APP_NAME.app"
    mkdir -p "$HOME/Applications"
    rm -rf "$DEST"
    ditto "$APP" "$DEST"
fi

pkill -x "$APP_NAME" 2>/dev/null || true
sleep 0.3

if (( LOGIN )); then
    mkdir -p "$AGENT_DIR"
    if (( KEEP_ALIVE )); then
        KEEP_ALIVE_XML="<key>KeepAlive</key><true/>"
    else
        KEEP_ALIVE_XML="<key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>"
    fi

    cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$DEST/Contents/MacOS/$APP_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    $KEEP_ALIVE_XML
    <key>ProcessType</key>
    <string>Interactive</string>
    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
    <key>ThrottleInterval</key>
    <integer>5</integer>
</dict>
</plist>
PLIST

    stop_agent
    launchctl bootstrap "gui/$UID_NUM" "$AGENT"
    launchctl kickstart -k "gui/$UID_NUM/$LABEL" 2>/dev/null || true
else
    stop_agent
    rm -f "$AGENT"
    open "$DEST"
fi

echo ""
echo "Installed:  $DEST"
if (( LOGIN )); then
    echo "Auto-start: $AGENT"
else
    echo "Auto-start: disabled"
fi
echo "Settings are saved in ~/Library/Preferences/$LABEL.plist"
echo ""
echo "For snow on the Dock, allow Accessibility:"
echo "  System Settings → Privacy & Security → Accessibility → $APP_NAME"
echo ""
echo "Uninstall everything with:"
echo "  zsh install.sh --uninstall"
