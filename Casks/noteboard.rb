# 按实际 Mac CPU 选择上游发布的 DMG，并固定每个安装包的 SHA-256。
cask "noteboard" do
  arch arm: "aarch64", intel: "x64"

  version "0.8.6"
  sha256 arm:   "af93a80a03af74b85a7e07d641566a3df18c70d37c6e1afcc3b3367217a0891a",
         intel: "f247fceca57a354e70311f543b8f0156ea0dd6e7ef663a075f20fa0ba1b614e1"

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
