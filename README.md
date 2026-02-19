# zup

Windows向けの簡易 Obtainium 風ツールです。  
現時点では **GitHub Releases の latest にある zip アセットのみ** を対象にします。

## 機能

- GitHub URL を追加して管理（例: `https://github.com/owner/repo`）
- SQLite で以下を保存
  - リポジトリURL
  - zipフィルタ正規表現
  - インストール先ディレクトリ
  - インストール済みバージョン
  - 最後に使ったzip名
- 正規表現 + `.zip` 条件で latest release のアセットを選択
- zip をダウンロードして指定フォルダへ展開
- Linux でもUI起動・確認可能

## 使い方

1. `Add URL` で登録
2. `GitHub URL`, `zip フィルタ正規表現`, `インストール先` を入力
3. `Check latest` で解決されるバージョン/zipを確認
4. `Install` / `Update` でダウンロード・展開

## 開発

```bash
flutter pub get
flutter analyze
flutter test
```

LinuxでUI確認:

```bash
flutter run -d linux
```

Linuxビルド確認:

```bash
flutter build linux --debug
```
