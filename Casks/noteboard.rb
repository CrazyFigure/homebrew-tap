# 按实际 Mac CPU 选择上游发布的 DMG，并固定每个安装包的 SHA-256。
cask "noteboard" do
  arch arm: "aarch64", intel: "x64"

  version "0.9.3"
  sha256 arm:   "68d6df6225eaa9dfcc9150778ef5bec4b9f7beff7af46a3bf93ddfde71e53437",
         intel: "f9a308c1fc7e128b3a9424a6bcdd1ea855cf8b8fb907cf550e3a3ecdedf2e3ac"

  url "https://github.com/CrazyFigure/NoteBoard/releases/download/v#{version}/NoteBoard_#{version}_#{arch}.dmg"
  name "NoteBoard"
  desc "Markdown notes, whiteboards, tables and mind maps"
  homepage "https://github.com/CrazyFigure/NoteBoard"

  depends_on macos: :monterey

  app "NoteBoard.app"

  caveats <<~EOS
    Current builds use ad-hoc signing and are not notarized by Apple.
  EOS
end
