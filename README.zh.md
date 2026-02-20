# Zup

<img src="assets/screenshot/hero.png" alt="Zup 主视觉界面" width="100%">

[English](README.md) | [日本語](README.ja.md)

## 产品介绍

Zup 是一个桌面端更新工具，用于从 GitHub Releases 的 ZIP 资源安装和更新应用。
你只需登记 GitHub 仓库 URL 与 ZIP 文件匹配正则，Zup 就会检查最新发布并把应用安装或更新到目标目录。

### 主要功能

- 按 GitHub 仓库 URL 注册并管理应用来源
- 使用正则表达式筛选 ZIP 资源
- 支持“仅稳定版”或“包含预发布版”两种模式
- 一键安装/更新，并保存已安装版本等元数据
- 可选 GitHub Personal Access Token，用于更高 API 限额和私有仓库访问
- 提供英文、日文、中文界面

### 截图

![Zup 首页界面](assets/screenshot/01.png)
![Zup 详情界面](assets/screenshot/02.png)
![Zup 设置界面](assets/screenshot/03.png)

## 开发

### 环境要求

- Flutter（本项目建议使用 beta 通道）
- 与 `sdk: ^3.11.0-200.1.beta` 兼容的 Dart SDK
- 对应操作系统的桌面开发工具链（Windows / macOS / Linux）

### 初始化

```bash
flutter pub get
```

### 运行

```bash
flutter run -d windows
# or: flutter run -d macos
# or: flutter run -d linux
```

### 测试与格式化

```bash
flutter test
dart format .
```

### 可选（mise）

如果你使用 `mise`，项目已在 `mise.toml` 中提供工具和任务定义。

```bash
mise install
mise run updateDeps
mise run genAppIcons
mise run format
```
