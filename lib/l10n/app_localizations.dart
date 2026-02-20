import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zup'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get settingsSaved;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GitHub Release ZIP Installer'**
  String get homeSubtitle;

  /// No description provided for @homeReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get homeReload;

  /// No description provided for @homeAddUrl.
  ///
  /// In en, this message translates to:
  /// **'Add URL'**
  String get homeAddUrl;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @commonInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get commonInstall;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get commonBrowse;

  /// No description provided for @commonNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get commonNotInstalled;

  /// No description provided for @commonByOwner.
  ///
  /// In en, this message translates to:
  /// **'by {owner}'**
  String commonByOwner(Object owner);

  /// No description provided for @commonExitCode.
  ///
  /// In en, this message translates to:
  /// **'Exit code: {code}'**
  String commonExitCode(Object code);

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No apps registered yet'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a GitHub repository URL to fetch and extract ZIP assets from the latest release.'**
  String get emptyStateDescription;

  /// No description provided for @sourceAdded.
  ///
  /// In en, this message translates to:
  /// **'Source added.'**
  String get sourceAdded;

  /// No description provided for @errorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {detail}'**
  String errorLoadFailed(Object detail);

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {detail}'**
  String errorSaveFailed(Object detail);

  /// No description provided for @errorDuplicateGitHubUrl.
  ///
  /// In en, this message translates to:
  /// **'The same GitHub URL is already registered.'**
  String get errorDuplicateGitHubUrl;

  /// No description provided for @errorActionFailed.
  ///
  /// In en, this message translates to:
  /// **'{action} failed: {detail}'**
  String errorActionFailed(Object action, Object detail);

  /// No description provided for @settingsLanguageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSectionTitle;

  /// No description provided for @settingsLanguageSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Use Auto to follow your OS language. Or choose a specific language.'**
  String get settingsLanguageSectionDescription;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Display language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (system)'**
  String get settingsLanguageAuto;

  /// No description provided for @settingsLanguageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get settingsLanguageJapanese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsDefaultInstallDirTitle.
  ///
  /// In en, this message translates to:
  /// **'Default install directory'**
  String get settingsDefaultInstallDirTitle;

  /// No description provided for @settingsDefaultInstallDirDescription.
  ///
  /// In en, this message translates to:
  /// **'If install path is empty when registering an app, \"default path/app name\" will be used.'**
  String get settingsDefaultInstallDirDescription;

  /// No description provided for @settingsDefaultInstallDirExample.
  ///
  /// In en, this message translates to:
  /// **'Example: C:\\Tools or /opt/tools'**
  String get settingsDefaultInstallDirExample;

  /// No description provided for @settingsGitHubTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'GitHub Personal Access Token (optional)'**
  String get settingsGitHubTokenTitle;

  /// No description provided for @settingsGitHubTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'If set, this token is used for GitHub API calls. Useful for higher rate limits and private repositories.'**
  String get settingsGitHubTokenDescription;

  /// No description provided for @settingsGitHubTokenHelper.
  ///
  /// In en, this message translates to:
  /// **'Saving with empty value removes the token'**
  String get settingsGitHubTokenHelper;

  /// No description provided for @editorTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add GitHub URL'**
  String get editorTitleAdd;

  /// No description provided for @editorTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit registration'**
  String get editorTitleEdit;

  /// No description provided for @editorGitHubUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub URL'**
  String get editorGitHubUrlLabel;

  /// No description provided for @editorZipRegexLabel.
  ///
  /// In en, this message translates to:
  /// **'ZIP filter regex'**
  String get editorZipRegexLabel;

  /// No description provided for @editorInstallDirLabel.
  ///
  /// In en, this message translates to:
  /// **'Install directory'**
  String get editorInstallDirLabel;

  /// No description provided for @editorDefaultPathNotice.
  ///
  /// In en, this message translates to:
  /// **'If left empty or set to the default path, \"{basePath}/{repo}\" will be used.'**
  String editorDefaultPathNotice(Object basePath, Object repo);

  /// No description provided for @editorLatestReleaseNote.
  ///
  /// In en, this message translates to:
  /// **'Note: only ZIP assets from the latest release are supported.'**
  String get editorLatestReleaseNote;

  /// No description provided for @editorErrorGitHubUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a GitHub URL.'**
  String get editorErrorGitHubUrlRequired;

  /// No description provided for @editorErrorZipRegexRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a regex for ZIP filtering.'**
  String get editorErrorZipRegexRequired;

  /// No description provided for @editorErrorInstallDirRequired.
  ///
  /// In en, this message translates to:
  /// **'Install directory is empty. Set a default directory in Settings or enter one here.'**
  String get editorErrorInstallDirRequired;

  /// No description provided for @detailPageTitle.
  ///
  /// In en, this message translates to:
  /// **'App details'**
  String get detailPageTitle;

  /// No description provided for @detailCheckLatest.
  ///
  /// In en, this message translates to:
  /// **'Check latest'**
  String get detailCheckLatest;

  /// No description provided for @detailOpenLocation.
  ///
  /// In en, this message translates to:
  /// **'Open location'**
  String get detailOpenLocation;

  /// No description provided for @detailUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated: {dateTime}'**
  String detailUpdatedAt(Object dateTime);

  /// No description provided for @detailCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current: {version}'**
  String detailCurrentVersion(Object version);

  /// No description provided for @detailLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest: {version}'**
  String detailLatestVersion(Object version);

  /// No description provided for @detailSelectedZip.
  ///
  /// In en, this message translates to:
  /// **'Selected ZIP: {name}'**
  String detailSelectedZip(Object name);

  /// No description provided for @detailMatchedAssetCount.
  ///
  /// In en, this message translates to:
  /// **'Matched assets: {count}'**
  String detailMatchedAssetCount(Object count);

  /// No description provided for @detailUpdatedToVersion.
  ///
  /// In en, this message translates to:
  /// **'Updated {app} to {version}.'**
  String detailUpdatedToVersion(Object app, Object version);

  /// No description provided for @detailRegistrationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Registration updated.'**
  String get detailRegistrationUpdated;

  /// No description provided for @detailInstallDirNotFound.
  ///
  /// In en, this message translates to:
  /// **'Install directory not found: {path}'**
  String detailInstallDirNotFound(Object path);

  /// No description provided for @detailFailedToOpenExplorer.
  ///
  /// In en, this message translates to:
  /// **'Failed to open file explorer: {detail}'**
  String detailFailedToOpenExplorer(Object detail);

  /// No description provided for @detailUnsupportedOpenLocation.
  ///
  /// In en, this message translates to:
  /// **'Open location is not supported on this OS.'**
  String get detailUnsupportedOpenLocation;

  /// No description provided for @detailDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete registration'**
  String get detailDeleteDialogTitle;

  /// No description provided for @detailDeleteTarget.
  ///
  /// In en, this message translates to:
  /// **'Delete {target}.'**
  String detailDeleteTarget(Object target);

  /// No description provided for @detailDeleteDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how to delete.'**
  String get detailDeleteDialogDescription;

  /// No description provided for @detailInstallDestination.
  ///
  /// In en, this message translates to:
  /// **'Install destination: {path}'**
  String detailInstallDestination(Object path);

  /// No description provided for @detailDeleteRegistrationOnly.
  ///
  /// In en, this message translates to:
  /// **'Delete registration only'**
  String get detailDeleteRegistrationOnly;

  /// No description provided for @detailDeleteRegistrationAndFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete folder too'**
  String get detailDeleteRegistrationAndFolder;

  /// No description provided for @detailDeleteWithFolderAction.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get detailDeleteWithFolderAction;

  /// No description provided for @detailErrorFileOperationFailedAppRunning.
  ///
  /// In en, this message translates to:
  /// **'File operation failed. The app may be running. Close it and try again.'**
  String get detailErrorFileOperationFailedAppRunning;

  /// No description provided for @detailErrorActionFailedAppRunning.
  ///
  /// In en, this message translates to:
  /// **'{action} failed. The app may be running. Close it and try again.'**
  String detailErrorActionFailedAppRunning(Object action);

  /// No description provided for @detailFieldGitHubUrl.
  ///
  /// In en, this message translates to:
  /// **'GitHub URL'**
  String get detailFieldGitHubUrl;

  /// No description provided for @detailFieldOwnerRepo.
  ///
  /// In en, this message translates to:
  /// **'Owner/Repo'**
  String get detailFieldOwnerRepo;

  /// No description provided for @detailFieldAssetRegex.
  ///
  /// In en, this message translates to:
  /// **'Asset Regex'**
  String get detailFieldAssetRegex;

  /// No description provided for @detailFieldInstallDir.
  ///
  /// In en, this message translates to:
  /// **'Install Dir'**
  String get detailFieldInstallDir;

  /// No description provided for @detailFieldInstalledVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed Version'**
  String get detailFieldInstalledVersion;

  /// No description provided for @detailFieldLastZip.
  ///
  /// In en, this message translates to:
  /// **'Last ZIP'**
  String get detailFieldLastZip;

  /// No description provided for @detailFieldLaunchExe.
  ///
  /// In en, this message translates to:
  /// **'Launch EXE'**
  String get detailFieldLaunchExe;

  /// No description provided for @detailFieldIconPath.
  ///
  /// In en, this message translates to:
  /// **'Icon Path'**
  String get detailFieldIconPath;

  /// No description provided for @detailFieldUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get detailFieldUpdated;

  /// No description provided for @errorGitHubUrlEmpty.
  ///
  /// In en, this message translates to:
  /// **'GitHub URL is empty.'**
  String get errorGitHubUrlEmpty;

  /// No description provided for @errorGitHubUrlInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'GitHub URL format is invalid.'**
  String get errorGitHubUrlInvalidFormat;

  /// No description provided for @errorGitHubUrlOwnerRepoMissing.
  ///
  /// In en, this message translates to:
  /// **'Specify a GitHub URL that includes owner/repo.'**
  String get errorGitHubUrlOwnerRepoMissing;

  /// No description provided for @errorGitHubApiUrlUnsupported.
  ///
  /// In en, this message translates to:
  /// **'GitHub API URL supports only /repos/owner/repo format.'**
  String get errorGitHubApiUrlUnsupported;

  /// No description provided for @errorGitHubDomainUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Only github.com URLs are supported.'**
  String get errorGitHubDomainUnsupported;

  /// No description provided for @errorGitHubRepoNameUnresolved.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve the repository name.'**
  String get errorGitHubRepoNameUnresolved;

  /// No description provided for @errorGitHubLatestReleaseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Latest release not found: {repo}'**
  String errorGitHubLatestReleaseNotFound(Object repo);

  /// No description provided for @errorGitHubRateLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'GitHub API rate limit exceeded. Please retry later.'**
  String get errorGitHubRateLimitExceeded;

  /// No description provided for @errorGitHubApi.
  ///
  /// In en, this message translates to:
  /// **'GitHub API error ({statusCode}): {detail}'**
  String errorGitHubApi(Object statusCode, Object detail);

  /// No description provided for @errorGitHubResponseParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse GitHub response.'**
  String get errorGitHubResponseParseFailed;

  /// No description provided for @errorGitHubAssetsInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Release assets format is invalid.'**
  String get errorGitHubAssetsInvalidFormat;

  /// No description provided for @errorGitHubAssetNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No ZIP matched the regex: {regex}'**
  String errorGitHubAssetNoMatch(Object regex);

  /// No description provided for @errorGitHubAssetRegexInvalid.
  ///
  /// In en, this message translates to:
  /// **'Regex is invalid: {detail}'**
  String errorGitHubAssetRegexInvalid(Object detail);

  /// No description provided for @errorZipDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download ZIP ({statusCode}): {assetName}'**
  String errorZipDownloadFailed(Object statusCode, Object assetName);

  /// No description provided for @errorZipEmpty.
  ///
  /// In en, this message translates to:
  /// **'ZIP is empty.'**
  String get errorZipEmpty;

  /// No description provided for @errorZipInvalidPath.
  ///
  /// In en, this message translates to:
  /// **'ZIP contains an invalid path: {path}'**
  String errorZipInvalidPath(Object path);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
