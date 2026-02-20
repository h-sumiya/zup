# Zup

<img src="assets/screenshot/hero.png" alt="Zup ヒーロー画面" width="100%">

[English](README.md) | [中文](README.zh.md)

## 製品紹介

Zup は、GitHub Releases で配布される ZIP アセットからデスクトップアプリを導入・更新するためのツールです。
GitHub リポジトリ URL と ZIP の正規表現を登録すると、最新リリースを確認して指定ディレクトリへインストールまたは更新できます。

### 主な機能

- GitHub リポジトリ URL 単位でアプリを登録して管理
- 正規表現で ZIP アセットを選択
- 安定版のみ / プレリリース含む の切り替え
- インストール・更新とバージョン情報の保存
- GitHub Personal Access Token（任意）による API 制限緩和・プライベートリポジトリ対応
- 英語・日本語・中国語の UI ローカライズ

### スクリーンショット

![Zup ホーム画面](assets/screenshot/01.png)
![Zup 詳細画面](assets/screenshot/02.png)
![Zup 設定画面](assets/screenshot/03.png)

## 開発

### 必要環境

- Flutter（このプロジェクトでは beta チャンネル推奨）
- `sdk: ^3.11.0-200.1.beta` に互換性のある Dart SDK
- 利用 OS 向けデスクトップ開発ツールチェーン（Windows / macOS / Linux）

### セットアップ

```bash
flutter pub get
```

### 実行

```bash
flutter run -d windows
# or: flutter run -d macos
# or: flutter run -d linux
```

### テストと整形

```bash
flutter test
dart format .
```

### 任意（mise）

`mise` を使う場合、`mise.toml` にツール/タスク定義があります。

```bash
mise install
mise run updateDeps
mise run genAppIcons
mise run format
```
