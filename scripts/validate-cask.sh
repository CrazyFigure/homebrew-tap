#!/usr/bin/env bash
# 在临时应用目录安装正式 DMG，核验身份、版本和签名完整性；退出时清理测试安装。
set -euo pipefail
app_dir="$RUNNER_TEMP/noteboard-cask-apps"
app_path="$app_dir/NoteBoard.app"
version=$(sed -nE 's/^  version "([^"]+)"/\1/p' Casks/noteboard.rb)
mkdir -p "$app_dir"
brew tap --custom-remote crazyfigure/tap "$GITHUB_WORKSPACE"
# 新版 Homebrew 要求显式信任自有 Tap；只信任本次测试的一个 Cask。
if brew command trust >/dev/null 2>&1; then
  brew trust --cask crazyfigure/tap/noteboard
fi
brew style --cask crazyfigure/tap/noteboard
brew fetch --cask crazyfigure/tap/noteboard
trap 'brew uninstall --cask crazyfigure/tap/noteboard || true' EXIT
brew install --cask --appdir="$app_dir" crazyfigure/tap/noteboard
test "$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app_path/Contents/Info.plist")" = com.crazyfigure.noteboard
test "$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app_path/Contents/Info.plist")" = "$version"
# ad-hoc 签名仅用于完整性检查；不将此结果当作 Apple 公证或 Gatekeeper 认可。
codesign --verify --deep --strict "$app_path"
file "$app_path/Contents/MacOS/NoteBoard"
# 防止架构映射写反后仍在 Rosetta 环境中被误判为正确安装。
lipo -verify_arch "$(uname -m)" "$app_path/Contents/MacOS/NoteBoard"
# 正常路径显式核验卸载结果；退出陷阱仅用于失败时尽量清理。
brew uninstall --cask crazyfigure/tap/noteboard
test ! -e "$app_path"
trap - EXIT
