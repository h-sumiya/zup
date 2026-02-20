enum AppExceptionCode {
  githubUrlEmpty,
  githubUrlInvalidFormat,
  githubUrlOwnerRepoMissing,
  githubApiUrlUnsupported,
  githubDomainUnsupported,
  githubRepoNameUnresolved,
  githubLatestReleaseNotFound,
  githubRateLimitExceeded,
  githubApiError,
  githubResponseParseFailed,
  githubAssetsInvalidFormat,
  githubAssetNoMatch,
  githubAssetRegexInvalid,
  zipDownloadFailed,
  zipEmpty,
  zipInvalidPath,
}

class AppException implements Exception {
  const AppException(this.code, {this.values = const <String, Object?>{}});

  final AppExceptionCode code;
  final Map<String, Object?> values;

  Object? operator [](String key) => values[key];

  @override
  String toString() => 'AppException($code, $values)';
}
