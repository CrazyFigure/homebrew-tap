# 按实际 Mac CPU 选择上游发布的 DMG，并固定每个安装包的 SHA-256。
cask "noteboard" do
  arch arm: "aarch64", intel: "x64"

  version "0.6.5"
  sha256 arm:   "0ab1b003e8a09bb093880bc2e17ad70c9d191f18d9347cd991fcd073da8b1d71",
         intel: "52caa100f2a5210db2f42d7508af0f3d57ee96995f92a3dbaf6001b4b9e9c6b9"

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
