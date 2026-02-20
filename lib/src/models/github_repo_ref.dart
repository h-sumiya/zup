import '../errors/app_exception.dart';

class GitHubRepoRef {
  const GitHubRepoRef({required this.owner, required this.repo});

  final String owner;
  final String repo;

  String get canonicalUrl => 'https://github.com/$owner/$repo';

  static GitHubRepoRef fromUrl(String source) {
    final raw = source.trim();
    if (raw.isEmpty) {
      throw const AppException(AppExceptionCode.githubUrlEmpty);
    }

    final normalized = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasAuthority) {
      throw const AppException(AppExceptionCode.githubUrlInvalidFormat);
    }

    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.length < 2) {
      throw const AppException(AppExceptionCode.githubUrlOwnerRepoMissing);
    }

    if (uri.host == 'api.github.com') {
      if (segments.length < 3 || segments.first != 'repos') {
        throw const AppException(AppExceptionCode.githubApiUrlUnsupported);
      }
      return GitHubRepoRef(
        owner: segments[1],
        repo: _normalizeRepoName(segments[2]),
      );
    }

    if (uri.host != 'github.com' && uri.host != 'www.github.com') {
      throw const AppException(AppExceptionCode.githubDomainUnsupported);
    }

    return GitHubRepoRef(
      owner: segments[0],
      repo: _normalizeRepoName(segments[1]),
    );
  }

  static String _normalizeRepoName(String value) {
    final sanitized = value.endsWith('.git')
        ? value.substring(0, value.length - 4)
        : value;
    if (sanitized.isEmpty) {
      throw const AppException(AppExceptionCode.githubRepoNameUnresolved);
    }
    return sanitized;
  }
}
