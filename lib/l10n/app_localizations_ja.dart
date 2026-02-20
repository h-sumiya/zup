// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Zup';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSaved => '設定を保存しました。';

  @override
  String get homeSubtitle => 'GitHub Release ZIP Installer';

  @override
  String get homeReload => '再読み込み';

  @override
  String get homeAddUrl => 'URLを追加';

  @override
  String get commonSave => '保存';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonAdd => '追加';

  @override
  String get commonUpdate => '更新';

  @override
  String get commonInstall => 'インストール';

  @override
  String get commonEdit => '編集';

  @override
  String get commonDelete => '削除';

  @override
  String get commonBrowse => '参照';

  @override
  String get commonNotInstalled => '未インストール';

  @override
  String commonByOwner(Object owner) {
    return 'by $owner';
  }

  @override
  String commonExitCode(Object code) {
    return '終了コード: $code';
  }

  @override
  String get emptyStateTitle => '登録されたアプリはまだありません';

  @override
  String get emptyStateDescription =>
      'GitHubのリポジトリURLを追加すると、latest release から ZIP を取得して展開できます。';

  @override
  String get sourceAdded => 'ソースを追加しました。';

  @override
  String errorLoadFailed(Object detail) {
    return '読み込みに失敗しました: $detail';
  }

  @override
  String errorSaveFailed(Object detail) {
    return '保存に失敗しました: $detail';
  }

  @override
  String get errorDuplicateGitHubUrl => '同じGitHub URLはすでに登録されています。';

  @override
  String errorActionFailed(Object action, Object detail) {
    return '$actionに失敗しました: $detail';
  }

  @override
  String get settingsLanguageSectionTitle => '言語';

  @override
  String get settingsLanguageSectionDescription =>
      '「自動」はOSの言語に追従します。固定したい場合は明示的に選択してください。';

  @override
  String get settingsLanguageLabel => '表示言語';

  @override
  String get settingsLanguageAuto => '自動（システム）';

  @override
  String get settingsLanguageJapanese => '日本語';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsDefaultInstallDirTitle => 'デフォルトインストールディレクトリ';

  @override
  String get settingsDefaultInstallDirDescription =>
      '新規登録時、空欄なら「デフォルトパス/アプリ名」を採用します。';

  @override
  String get settingsDefaultInstallDirExample => '例: C:\\Tools または /opt/tools';

  @override
  String get settingsGitHubTokenTitle => 'GitHub Personal Access Token（任意）';

  @override
  String get settingsGitHubTokenDescription =>
      '設定すると GitHub API 呼び出しに利用します。レート制限緩和や private repository へのアクセスに使えます。';

  @override
  String get settingsGitHubTokenHelper => '空欄で保存すると削除されます';

  @override
  String get editorTitleAdd => 'GitHub URLを追加';

  @override
  String get editorTitleEdit => '登録を編集';

  @override
  String get editorGitHubUrlLabel => 'GitHub URL';

  @override
  String get editorZipRegexLabel => 'ZIP フィルタ正規表現';

  @override
  String get editorInstallDirLabel => 'インストール先ディレクトリ';

  @override
  String editorDefaultPathNotice(Object basePath, Object repo) {
    return '空欄またはデフォルトパス指定時は「$basePath/$repo」を採用します。';
  }

  @override
  String get editorLatestReleaseNote => '注: 対象は latest release の ZIP アセットのみです。';

  @override
  String get editorErrorGitHubUrlRequired => 'GitHub URLを入力してください。';

  @override
  String get editorErrorZipRegexRequired => 'ZIPフィルタ用の正規表現を入力してください。';

  @override
  String get editorErrorInstallDirRequired =>
      'インストール先が空です。設定画面でデフォルトディレクトリを指定するか、ここで入力してください。';

  @override
  String get detailPageTitle => 'アプリ詳細';

  @override
  String get detailCheckLatest => '最新を確認';

  @override
  String get detailOpenLocation => '場所を開く';

  @override
  String detailUpdatedAt(Object dateTime) {
    return '最終更新: $dateTime';
  }

  @override
  String detailCurrentVersion(Object version) {
    return '現在: $version';
  }

  @override
  String detailLatestVersion(Object version) {
    return '最新: $version';
  }

  @override
  String detailSelectedZip(Object name) {
    return '選択ZIP: $name';
  }

  @override
  String detailMatchedAssetCount(Object count) {
    return '一致候補: $count件';
  }

  @override
  String detailUpdatedToVersion(Object app, Object version) {
    return '$app を $version に更新しました。';
  }

  @override
  String get detailRegistrationUpdated => '登録を更新しました。';

  @override
  String detailInstallDirNotFound(Object path) {
    return 'インストール先フォルダが見つかりません: $path';
  }

  @override
  String detailFailedToOpenExplorer(Object detail) {
    return 'エクスプローラを起動できませんでした: $detail';
  }

  @override
  String get detailUnsupportedOpenLocation => 'このOSでは場所を開く機能を利用できません。';

  @override
  String get detailDeleteDialogTitle => '登録を削除';

  @override
  String detailDeleteTarget(Object target) {
    return '$target を削除します。';
  }

  @override
  String get detailDeleteDialogDescription => '削除方法を選択してください。';

  @override
  String detailInstallDestination(Object path) {
    return 'インストール先: $path';
  }

  @override
  String get detailDeleteRegistrationOnly => '登録のみ削除';

  @override
  String get detailDeleteRegistrationAndFolder => 'フォルダも削除';

  @override
  String get detailDeleteWithFolderAction => 'フォルダ削除';

  @override
  String get detailErrorFileOperationFailedAppRunning =>
      'ファイル操作に失敗しました。対象アプリが実行中の可能性があります。終了して再試行してください。';

  @override
  String detailErrorActionFailedAppRunning(Object action) {
    return '$actionに失敗しました。対象アプリが実行中の可能性があります。終了して再試行してください。';
  }

  @override
  String get detailFieldGitHubUrl => 'GitHub URL';

  @override
  String get detailFieldOwnerRepo => 'Owner/Repo';

  @override
  String get detailFieldAssetRegex => 'Asset Regex';

  @override
  String get detailFieldInstallDir => 'Install Dir';

  @override
  String get detailFieldInstalledVersion => 'Installed Version';

  @override
  String get detailFieldLastZip => 'Last ZIP';

  @override
  String get detailFieldLaunchExe => 'Launch EXE';

  @override
  String get detailFieldIconPath => 'Icon Path';

  @override
  String get detailFieldUpdated => 'Updated';

  @override
  String get errorGitHubUrlEmpty => 'GitHub URLが空です。';

  @override
  String get errorGitHubUrlInvalidFormat => 'GitHub URLの形式が不正です。';

  @override
  String get errorGitHubUrlOwnerRepoMissing =>
      'owner/repo を含むGitHub URLを指定してください。';

  @override
  String get errorGitHubApiUrlUnsupported =>
      'GitHub API URLは /repos/owner/repo 形式のみ対応です。';

  @override
  String get errorGitHubDomainUnsupported => 'github.com のURLのみ対応です。';

  @override
  String get errorGitHubRepoNameUnresolved => 'repo名を解決できませんでした。';

  @override
  String errorGitHubLatestReleaseNotFound(Object repo) {
    return 'latest release が見つかりません: $repo';
  }

  @override
  String get errorGitHubRateLimitExceeded =>
      'GitHub API rate limitに達しました。時間を置いて再試行してください。';

  @override
  String errorGitHubApi(Object statusCode, Object detail) {
    return 'GitHub APIエラー($statusCode): $detail';
  }

  @override
  String get errorGitHubResponseParseFailed => 'GitHubレスポンスの解析に失敗しました。';

  @override
  String get errorGitHubAssetsInvalidFormat => 'release assetsの形式が不正です。';

  @override
  String errorGitHubAssetNoMatch(Object regex) {
    return '正規表現に一致するZIPが見つかりません: $regex';
  }

  @override
  String errorGitHubAssetRegexInvalid(Object detail) {
    return '正規表現が不正です: $detail';
  }

  @override
  String errorZipDownloadFailed(Object statusCode, Object assetName) {
    return 'ZIPのダウンロードに失敗しました ($statusCode): $assetName';
  }

  @override
  String get errorZipEmpty => 'ZIPが空です。';

  @override
  String errorZipInvalidPath(Object path) {
    return 'ZIP内に不正なパスが含まれています: $path';
  }
}
