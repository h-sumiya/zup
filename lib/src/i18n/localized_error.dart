import 'package:flutter/widgets.dart';
import 'package:zup/l10n/app_localizations.dart';

import '../errors/app_exception.dart';

String localizeErrorMessage(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context)!;

  if (error is AppException) {
    switch (error.code) {
      case AppExceptionCode.githubUrlEmpty:
        return l10n.errorGitHubUrlEmpty;
      case AppExceptionCode.githubUrlInvalidFormat:
        return l10n.errorGitHubUrlInvalidFormat;
      case AppExceptionCode.githubUrlOwnerRepoMissing:
        return l10n.errorGitHubUrlOwnerRepoMissing;
      case AppExceptionCode.githubApiUrlUnsupported:
        return l10n.errorGitHubApiUrlUnsupported;
      case AppExceptionCode.githubDomainUnsupported:
        return l10n.errorGitHubDomainUnsupported;
      case AppExceptionCode.githubRepoNameUnresolved:
        return l10n.errorGitHubRepoNameUnresolved;
      case AppExceptionCode.githubLatestReleaseNotFound:
        return l10n.errorGitHubLatestReleaseNotFound(_value(error, 'repo'));
      case AppExceptionCode.githubRateLimitExceeded:
        return l10n.errorGitHubRateLimitExceeded;
      case AppExceptionCode.githubApiError:
        return l10n.errorGitHubApi(
          _value(error, 'statusCode'),
          _value(error, 'detail'),
        );
      case AppExceptionCode.githubResponseParseFailed:
        return l10n.errorGitHubResponseParseFailed;
      case AppExceptionCode.githubAssetsInvalidFormat:
        return l10n.errorGitHubAssetsInvalidFormat;
      case AppExceptionCode.githubAssetNoMatch:
        return l10n.errorGitHubAssetNoMatch(_value(error, 'regex'));
      case AppExceptionCode.githubAssetRegexInvalid:
        return l10n.errorGitHubAssetRegexInvalid(_value(error, 'detail'));
      case AppExceptionCode.zipDownloadFailed:
        return l10n.errorZipDownloadFailed(
          _value(error, 'statusCode'),
          _value(error, 'assetName'),
        );
      case AppExceptionCode.zipEmpty:
        return l10n.errorZipEmpty;
      case AppExceptionCode.zipInvalidPath:
        return l10n.errorZipInvalidPath(_value(error, 'path'));
    }
  }

  return normalizeErrorMessage(error.toString());
}

String normalizeErrorMessage(String raw) {
  const prefixes = <String>[
    'FormatException: ',
    'Exception: ',
    'FileSystemException: ',
    'ProcessException: ',
    'Unsupported operation: ',
  ];
  for (final prefix in prefixes) {
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
  }
  return raw;
}

String _value(AppException error, String key) {
  final value = error[key];
  if (value == null) {
    return '';
  }
  return value.toString();
}
