# CrazyFigure Homebrew Tap

项目维护的 Homebrew Tap，目前提供 [NoteBoard](https://github.com/CrazyFigure/NoteBoard) 的 macOS 安装与更新，自动选择 Apple Silicon / Intel 安装包。

```bash
# 安装（使用完整名称，只信任此 Cask）
brew install --cask crazyfigure/tap/noteboard

# 更新
brew update
brew upgrade --cask crazyfigure/tap/noteboard

# 卸载应用，保留笔记与设置
brew uninstall --cask crazyfigure/tap/noteboard
```

要求 macOS 12+。当前安装包使用 ad-hoc 签名，未经过 Apple 公证；首次启动可能需要在“系统设置 → 隐私与安全性”中允许打开。此仓库由项目维护，不属于 Homebrew 官方主仓。

每 6 小时检查上游最新正式 Release；两个架构的 DMG 齐全、下载内容与 SHA-256 一致且安装验证通过后，才更新 Cask。同版本附件校验值发生变化时停止自动更新并报告错误。也可在 Actions 中手动运行 **Update NoteBoard**。
