# 按实际 Mac CPU 选择上游发布的 DMG，并固定每个安装包的 SHA-256。
cask "noteboard" do
  arch arm: "aarch64", intel: "x64"

  version "0.7.8"
  sha256 arm:   "bb53d6155ff8a9eea034db818bc885f04648cc8e52556e03916c40e74c0828e7",
         intel: "16a13004bdf72198db16572b13b6fdea7b4ff1082c238270b5cc19ff3b298363"

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
