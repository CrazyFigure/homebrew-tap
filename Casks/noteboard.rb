# 按实际 Mac CPU 选择上游发布的 DMG，并固定每个安装包的 SHA-256。
cask "noteboard" do
  arch arm: "aarch64", intel: "x64"

  version "0.5.9"
  sha256 arm:   "7eeaa28f0d9d23102bea59fbb7e1014d1ddbcd62c94914fdb3188d96a0f71bc3",
         intel: "18cf1ba102b856aea14e92536ee3c8bc7c3134bff7366c1dab7423441378f4bf"

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
