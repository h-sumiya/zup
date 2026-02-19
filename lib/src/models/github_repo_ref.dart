class GitHubRepoRef {
  const GitHubRepoRef({required this.owner, required this.repo});

  final String owner;
  final String repo;

  String get canonicalUrl => 'https://github.com/$owner/$repo';

  static GitHubRepoRef fromUrl(String source) {
    final raw = source.trim();
    if (raw.isEmpty) {
      throw const FormatException('GitHub URLが空です。');
    }

    final normalized = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasAuthority) {
      throw const FormatException('GitHub URLの形式が不正です。');
    }

    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.length < 2) {
      throw const FormatException('owner/repo を含むGitHub URLを指定してください。');
    }

    if (uri.host == 'api.github.com') {
      if (segments.length < 3 || segments.first != 'repos') {
        throw const FormatException(
          'GitHub API URLは /repos/{owner}/{repo} 形式のみ対応です。',
        );
      }
      return GitHubRepoRef(
        owner: segments[1],
        repo: _normalizeRepoName(segments[2]),
      );
    }

    if (uri.host != 'github.com' && uri.host != 'www.github.com') {
      throw const FormatException('github.com のURLのみ対応です。');
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
      throw const FormatException('repo名を解決できませんでした。');
    }
    return sanitized;
  }
}
