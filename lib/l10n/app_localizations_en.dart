// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zup';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String get homeSubtitle => 'GitHub Release ZIP Installer';

  @override
  String get homeReload => 'Reload';

  @override
  String get homeAddUrl => 'Add URL';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonUpdate => 'Update';

  @override
  String get commonInstall => 'Install';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonBrowse => 'Browse';

  @override
  String get commonNotInstalled => 'Not installed';

  @override
  String get commonEnabled => 'Enabled';

  @override
  String get commonDisabled => 'Disabled';

  @override
  String commonByOwner(Object owner) {
    return 'by $owner';
  }

  @override
  String commonExitCode(Object code) {
    return 'Exit code: $code';
  }

  @override
  String get emptyStateTitle => 'No apps registered yet';

  @override
  String get emptyStateDescription => 'Add a GitHub repository URL to fetch and extract ZIP assets from the latest release (including pre-release when enabled).';

  @override
  String get sourceAdded => 'Source added.';

  @override
  String errorLoadFailed(Object detail) {
    return 'Failed to load: $detail';
  }

  @override
  String errorSaveFailed(Object detail) {
    return 'Failed to save: $detail';
  }

  @override
  String get errorDuplicateGitHubUrl => 'The same GitHub URL is already registered.';

  @override
  String errorActionFailed(Object action, Object detail) {
    return '$action failed: $detail';
  }

  @override
  String get settingsLanguageSectionTitle => 'Language';

  @override
  String get settingsLanguageSectionDescription => 'Use Auto to follow your OS language. Or choose a specific language.';

  @override
  String get settingsLanguageLabel => 'Display language';

  @override
  String get settingsLanguageAuto => 'Auto (system)';

  @override
  String get settingsLanguageJapanese => 'Japanese';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => 'Chinese';

  @override
  String get settingsDefaultInstallDirTitle => 'Default install directory';

  @override
  String get settingsDefaultInstallDirDescription => 'If install path is empty when registering an app, \"default path/app name\" will be used.';

  @override
  String get settingsDefaultInstallDirExample => 'Example: C:\\Tools or /opt/tools';

  @override
  String get settingsGitHubTokenTitle => 'GitHub Personal Access Token (optional)';

  @override
  String get settingsGitHubTokenDescription => 'If set, this token is used for GitHub API calls. Useful for higher rate limits and private repositories.';

  @override
  String get settingsGitHubTokenHelper => 'Saving with empty value removes the token';

  @override
  String get editorTitleAdd => 'Add GitHub URL';

  @override
  String get editorTitleEdit => 'Edit registration';

  @override
  String get editorGitHubUrlLabel => 'GitHub URL';

  @override
  String get editorZipRegexLabel => 'ZIP filter regex';

  @override
  String get editorIncludePrereleaseLabel => 'Include pre-releases';

  @override
  String get editorInstallDirLabel => 'Install directory';

  @override
  String editorDefaultPathNotice(Object basePath, Object repo) {
    return 'If left empty or set to the default path, \"$basePath/$repo\" will be used.';
  }

  @override
  String get editorLatestReleaseNote => 'Note: OFF uses stable latest release. ON includes pre-releases in latest release selection (drafts are excluded).';

  @override
  String get editorErrorGitHubUrlRequired => 'Please enter a GitHub URL.';

  @override
  String get editorErrorZipRegexRequired => 'Please enter a regex for ZIP filtering.';

  @override
  String get editorErrorInstallDirRequired => 'Install directory is empty. Set a default directory in Settings or enter one here.';

  @override
  String get detailPageTitle => 'App details';

  @override
  String get detailCheckLatest => 'Check latest';

  @override
  String get detailOpenLocation => 'Open location';

  @override
  String detailUpdatedAt(Object dateTime) {
    return 'Updated: $dateTime';
  }

  @override
  String detailCurrentVersion(Object version) {
    return 'Current: $version';
  }

  @override
  String detailLatestVersion(Object version) {
    return 'Latest: $version';
  }

  @override
  String detailSelectedZip(Object name) {
    return 'Selected ZIP: $name';
  }

  @override
  String detailMatchedAssetCount(Object count) {
    return 'Matched assets: $count';
  }

  @override
  String detailUpdatedToVersion(Object app, Object version) {
    return 'Updated $app to $version.';
  }

  @override
  String get detailRegistrationUpdated => 'Registration updated.';

  @override
  String detailInstallDirNotFound(Object path) {
    return 'Install directory not found: $path';
  }

  @override
  String detailFailedToOpenExplorer(Object detail) {
    return 'Failed to open file explorer: $detail';
  }

  @override
  String get detailUnsupportedOpenLocation => 'Open location is not supported on this OS.';

  @override
  String get detailDeleteDialogTitle => 'Delete registration';

  @override
  String detailDeleteTarget(Object target) {
    return 'Delete $target.';
  }

  @override
  String get detailDeleteDialogDescription => 'Choose how to delete.';

  @override
  String detailInstallDestination(Object path) {
    return 'Install destination: $path';
  }

  @override
  String get detailDeleteRegistrationOnly => 'Delete registration only';

  @override
  String get detailDeleteRegistrationAndFolder => 'Delete folder too';

  @override
  String get detailDeleteWithFolderAction => 'Delete folder';

  @override
  String get detailErrorFileOperationFailedAppRunning => 'File operation failed. The app may be running. Close it and try again.';

  @override
  String detailErrorActionFailedAppRunning(Object action) {
    return '$action failed. The app may be running. Close it and try again.';
  }

  @override
  String get detailFieldGitHubUrl => 'GitHub URL';

  @override
  String get detailFieldOwnerRepo => 'Owner/Repo';

  @override
  String get detailFieldAssetRegex => 'Asset Regex';

  @override
  String get detailFieldIncludePrerelease => 'Include pre-releases';

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
  String get errorGitHubUrlEmpty => 'GitHub URL is empty.';

  @override
  String get errorGitHubUrlInvalidFormat => 'GitHub URL format is invalid.';

  @override
  String get errorGitHubUrlOwnerRepoMissing => 'Specify a GitHub URL that includes owner/repo.';

  @override
  String get errorGitHubApiUrlUnsupported => 'GitHub API URL supports only /repos/owner/repo format.';

  @override
  String get errorGitHubDomainUnsupported => 'Only github.com URLs are supported.';

  @override
  String get errorGitHubRepoNameUnresolved => 'Could not resolve the repository name.';

  @override
  String errorGitHubLatestReleaseNotFound(Object repo) {
    return 'Latest release not found: $repo';
  }

  @override
  String get errorGitHubRateLimitExceeded => 'GitHub API rate limit exceeded. Please retry later.';

  @override
  String errorGitHubApi(Object statusCode, Object detail) {
    return 'GitHub API error ($statusCode): $detail';
  }

  @override
  String get errorGitHubResponseParseFailed => 'Failed to parse GitHub response.';

  @override
  String get errorGitHubAssetsInvalidFormat => 'Release assets format is invalid.';

  @override
  String errorGitHubAssetNoMatch(Object regex) {
    return 'No ZIP matched the regex: $regex';
  }

  @override
  String errorGitHubAssetRegexInvalid(Object detail) {
    return 'Regex is invalid: $detail';
  }

  @override
  String errorZipDownloadFailed(Object statusCode, Object assetName) {
    return 'Failed to download ZIP ($statusCode): $assetName';
  }

  @override
  String get errorZipEmpty => 'ZIP is empty.';

  @override
  String errorZipInvalidPath(Object path) {
    return 'ZIP contains an invalid path: $path';
  }
}
