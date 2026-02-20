import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_app.dart';
import '../models/release_info.dart';

class GitHubReleaseClient {
  GitHubReleaseClient({Future<String?> Function()? tokenProvider})
    : _tokenProvider = tokenProvider;

  final Future<String?> Function()? _tokenProvider;
  final http.Client _client = http.Client();

  Future<ReleaseInfo> fetchLatestRelease(ManagedApp app) async {
    final token = (await _tokenProvider?.call())?.trim() ?? '';
    final uri = Uri.https(
      'api.github.com',
      '/repos/${app.owner}/${app.repo}/releases/latest',
    );
    final headers = <String, String>{
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'User-Agent': 'zup-flutter-client',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 404) {
      throw Exception('latest release が見つかりません: ${app.owner}/${app.repo}');
    }
    if (response.statusCode == 403 &&
        response.body.toLowerCase().contains('rate limit')) {
      throw Exception('GitHub API rate limitに達しました。時間を置いて再試行してください。');
    }
    if (response.statusCode != 200) {
      throw Exception(
        'GitHub APIエラー(${response.statusCode}): ${response.reasonPhrase ?? response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('GitHubレスポンスの解析に失敗しました。');
    }

    final regex = _compileRegex(app.assetRegex);
    final assetsRaw = decoded['assets'];
    if (assetsRaw is! List) {
      throw const FormatException('release assetsの形式が不正です。');
    }

    final matchingAssets = <ReleaseAssetInfo>[];
    for (final raw in assetsRaw) {
      if (raw is! Map) {
        continue;
      }
      final map = raw.cast<String, dynamic>();
      final name = map['name']?.toString() ?? '';
      final apiUrl = map['url']?.toString() ?? '';
      final browserUrl = map['browser_download_url']?.toString() ?? '';
      final url = apiUrl.isNotEmpty ? apiUrl : browserUrl;
      if (name.isEmpty || url.isEmpty) {
        continue;
      }
      if (!name.toLowerCase().endsWith('.zip')) {
        continue;
      }
      if (!regex.hasMatch(name)) {
        continue;
      }
      matchingAssets.add(
        ReleaseAssetInfo(
          name: name,
          downloadUrl: url,
          sizeBytes: (map['size'] as num?)?.toInt(),
        ),
      );
    }

    if (matchingAssets.isEmpty) {
      throw Exception('正規表現に一致するzipが見つかりません: ${app.assetRegex}');
    }

    final tagName = decoded['tag_name']?.toString().trim() ?? '';
    final releaseName = decoded['name']?.toString().trim() ?? '';
    final version = tagName.isNotEmpty
        ? tagName
        : releaseName.isNotEmpty
        ? releaseName
        : 'unknown';

    return ReleaseInfo(
      version: version,
      publishedAt: DateTime.tryParse(decoded['published_at']?.toString() ?? ''),
      selectedAsset: matchingAssets.first,
      matchedAssetCount: matchingAssets.length,
    );
  }

  void close() {
    _client.close();
  }

  RegExp _compileRegex(String expression) {
    try {
      return RegExp(expression, caseSensitive: false);
    } catch (error) {
      throw Exception('正規表現が不正です: $error');
    }
  }
}
