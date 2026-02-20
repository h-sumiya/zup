// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Zup';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSaved => '设置已保存。';

  @override
  String get homeSubtitle => 'GitHub Release ZIP Installer';

  @override
  String get homeReload => '刷新';

  @override
  String get homeAddUrl => '添加 URL';

  @override
  String get commonSave => '保存';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '关闭';

  @override
  String get commonAdd => '添加';

  @override
  String get commonUpdate => '更新';

  @override
  String get commonInstall => '安装';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonDelete => '删除';

  @override
  String get commonBrowse => '浏览';

  @override
  String get commonNotInstalled => '未安装';

  @override
  String get commonEnabled => '启用';

  @override
  String get commonDisabled => '禁用';

  @override
  String commonByOwner(Object owner) {
    return 'by $owner';
  }

  @override
  String commonExitCode(Object code) {
    return '退出码: $code';
  }

  @override
  String get emptyStateTitle => '尚未注册任何应用';

  @override
  String get emptyStateDescription => '添加 GitHub 仓库 URL 后，可从最新 release 下载并解压 ZIP（启用后可包含 pre-release）。';

  @override
  String get sourceAdded => '已添加来源。';

  @override
  String errorLoadFailed(Object detail) {
    return '加载失败: $detail';
  }

  @override
  String errorSaveFailed(Object detail) {
    return '保存失败: $detail';
  }

  @override
  String get errorDuplicateGitHubUrl => '相同的 GitHub URL 已注册。';

  @override
  String errorActionFailed(Object action, Object detail) {
    return '$action失败: $detail';
  }

  @override
  String get settingsLanguageSectionTitle => '语言';

  @override
  String get settingsLanguageSectionDescription => '选择“自动”将跟随系统语言，也可以手动固定语言。';

  @override
  String get settingsLanguageLabel => '显示语言';

  @override
  String get settingsLanguageAuto => '自动（系统）';

  @override
  String get settingsLanguageJapanese => '日本語';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsDefaultInstallDirTitle => '默认安装目录';

  @override
  String get settingsDefaultInstallDirDescription => '新建注册时若安装路径为空，将使用“默认路径/应用名”。';

  @override
  String get settingsDefaultInstallDirExample => '例如: C:\\Tools 或 /opt/tools';

  @override
  String get settingsGitHubTokenTitle => 'GitHub Personal Access Token（可选）';

  @override
  String get settingsGitHubTokenDescription => '设置后将用于 GitHub API 调用，可提升限流额度并访问私有仓库。';

  @override
  String get settingsGitHubTokenHelper => '留空保存会删除该 Token';

  @override
  String get editorTitleAdd => '添加 GitHub URL';

  @override
  String get editorTitleEdit => '编辑注册';

  @override
  String get editorGitHubUrlLabel => 'GitHub URL';

  @override
  String get editorZipRegexLabel => 'ZIP 过滤正则';

  @override
  String get editorIncludePrereleaseLabel => '包含 pre-release';

  @override
  String get editorInstallDirLabel => '安装目录';

  @override
  String editorDefaultPathNotice(Object basePath, Object repo) {
    return '若留空或与默认路径相同，将使用“$basePath/$repo”。';
  }

  @override
  String get editorLatestReleaseNote => '注意: 关闭时使用稳定版 latest release；开启时会把 pre-release 也纳入最新版本选择（不包含 draft）。';

  @override
  String get editorErrorGitHubUrlRequired => '请输入 GitHub URL。';

  @override
  String get editorErrorZipRegexRequired => '请输入 ZIP 过滤正则。';

  @override
  String get editorErrorInstallDirRequired => '安装目录为空。请在设置中指定默认目录，或在此处输入。';

  @override
  String get detailPageTitle => '应用详情';

  @override
  String get detailCheckLatest => '检查最新版本';

  @override
  String get detailOpenLocation => '打开位置';

  @override
  String detailUpdatedAt(Object dateTime) {
    return '最后更新: $dateTime';
  }

  @override
  String detailCurrentVersion(Object version) {
    return '当前: $version';
  }

  @override
  String detailLatestVersion(Object version) {
    return '最新: $version';
  }

  @override
  String detailSelectedZip(Object name) {
    return '已选 ZIP: $name';
  }

  @override
  String detailMatchedAssetCount(Object count) {
    return '匹配候选: $count';
  }

  @override
  String detailUpdatedToVersion(Object app, Object version) {
    return '已将 $app 更新到 $version。';
  }

  @override
  String get detailRegistrationUpdated => '注册信息已更新。';

  @override
  String detailInstallDirNotFound(Object path) {
    return '未找到安装目录: $path';
  }

  @override
  String detailFailedToOpenExplorer(Object detail) {
    return '无法打开文件管理器: $detail';
  }

  @override
  String get detailUnsupportedOpenLocation => '当前操作系统不支持打开位置功能。';

  @override
  String get detailDeleteDialogTitle => '删除注册';

  @override
  String detailDeleteTarget(Object target) {
    return '将删除 $target。';
  }

  @override
  String get detailDeleteDialogDescription => '请选择删除方式。';

  @override
  String detailInstallDestination(Object path) {
    return '安装位置: $path';
  }

  @override
  String get detailDeleteRegistrationOnly => '仅删除注册';

  @override
  String get detailDeleteRegistrationAndFolder => '同时删除文件夹';

  @override
  String get detailDeleteWithFolderAction => '删除文件夹';

  @override
  String get detailErrorFileOperationFailedAppRunning => '文件操作失败。目标应用可能仍在运行，请先关闭后重试。';

  @override
  String detailErrorActionFailedAppRunning(Object action) {
    return '$action失败。目标应用可能仍在运行，请先关闭后重试。';
  }

  @override
  String get detailFieldGitHubUrl => 'GitHub URL';

  @override
  String get detailFieldOwnerRepo => 'Owner/Repo';

  @override
  String get detailFieldAssetRegex => 'Asset Regex';

  @override
  String get detailFieldIncludePrerelease => '包含 pre-release';

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
  String get errorGitHubUrlEmpty => 'GitHub URL 为空。';

  @override
  String get errorGitHubUrlInvalidFormat => 'GitHub URL 格式不正确。';

  @override
  String get errorGitHubUrlOwnerRepoMissing => '请输入包含 owner/repo 的 GitHub URL。';

  @override
  String get errorGitHubApiUrlUnsupported => 'GitHub API URL 仅支持 /repos/owner/repo 格式。';

  @override
  String get errorGitHubDomainUnsupported => '仅支持 github.com 的 URL。';

  @override
  String get errorGitHubRepoNameUnresolved => '无法解析仓库名。';

  @override
  String errorGitHubLatestReleaseNotFound(Object repo) {
    return '未找到 latest release: $repo';
  }

  @override
  String get errorGitHubRateLimitExceeded => '已达到 GitHub API 限流，请稍后重试。';

  @override
  String errorGitHubApi(Object statusCode, Object detail) {
    return 'GitHub API 错误 ($statusCode): $detail';
  }

  @override
  String get errorGitHubResponseParseFailed => 'GitHub 响应解析失败。';

  @override
  String get errorGitHubAssetsInvalidFormat => 'Release assets 格式无效。';

  @override
  String errorGitHubAssetNoMatch(Object regex) {
    return '没有匹配正则的 ZIP: $regex';
  }

  @override
  String errorGitHubAssetRegexInvalid(Object detail) {
    return '正则无效: $detail';
  }

  @override
  String errorZipDownloadFailed(Object statusCode, Object assetName) {
    return 'ZIP 下载失败 ($statusCode): $assetName';
  }

  @override
  String get errorZipEmpty => 'ZIP 为空。';

  @override
  String errorZipInvalidPath(Object path) {
    return 'ZIP 中包含无效路径: $path';
  }
}
