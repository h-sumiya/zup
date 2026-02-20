import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import '../models/managed_app.dart';
import '../models/release_info.dart';

class GitHubReleaseClient {
  GitHubReleaseClient({Future<String?> Function()? tokenProvider})
    : _tokenProvider = tokenProvider;

  final Future<String?> Function()? _tokenProvider;
  final http.Client _client = http.Client();

  Future<ReleaseInfo> fetchLatestRelease(ManagedApp app) async {
    final token = (await _tokenProvider?.call())?.trim() ?? '';
    final headers = <String, String>{
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'User-Agent': 'zup-flutter-client',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final decoded = await _fetchReleasePayload(app, headers);

    final regex = _compileRegex(app.assetRegex);
    final assetsRaw = decoded['assets'];
    if (assetsRaw is! List) {
      throw const AppException(AppExceptionCode.githubAssetsInvalidFormat);
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
      throw AppException(
        AppExceptionCode.githubAssetNoMatch,
        values: <String, Object?>{'regex': app.assetRegex},
      );
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

  Future<Map<String, dynamic>> _fetchReleasePayload(
    ManagedApp app,
    Map<String, String> headers,
  ) async {
    if (app.includePrerelease) {
      return _fetchLatestReleaseIncludingPrerelease(app, headers);
    }

    final uri = Uri.https(
      'api.github.com',
      '/repos/${app.owner}/${app.repo}/releases/latest',
    );
    final response = await _client.get(uri, headers: headers);
    _validateReleaseApiResponse(response, app);

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const AppException(AppExceptionCode.githubResponseParseFailed);
    }
    return decoded;
  }

  Future<Map<String, dynamic>> _fetchLatestReleaseIncludingPrerelease(
    ManagedApp app,
    Map<String, String> headers,
  ) async {
    final uri = Uri.https(
      'api.github.com',
      '/repos/${app.owner}/${app.repo}/releases',
      <String, String>{'per_page': '20'},
    );
    final response = await _client.get(uri, headers: headers);
    _validateReleaseApiResponse(response, app);

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const AppException(AppExceptionCode.githubResponseParseFailed);
    }

    for (final raw in decoded) {
      if (raw is! Map) {
        continue;
      }
      final release = raw.cast<String, dynamic>();
      if (_isTruthy(release['draft'])) {
        continue;
      }
      return release;
    }

    throw AppException(
      AppExceptionCode.githubLatestReleaseNotFound,
      values: <String, Object?>{'repo': '${app.owner}/${app.repo}'},
    );
  }

  void _validateReleaseApiResponse(http.Response response, ManagedApp app) {
    if (response.statusCode == 404) {
      throw AppException(
        AppExceptionCode.githubLatestReleaseNotFound,
        values: <String, Object?>{'repo': '${app.owner}/${app.repo}'},
      );
    }
    if (response.statusCode == 403 &&
        response.body.toLowerCase().contains('rate limit')) {
      throw const AppException(AppExceptionCode.githubRateLimitExceeded);
    }
    if (response.statusCode != 200) {
      throw AppException(
        AppExceptionCode.githubApiError,
        values: <String, Object?>{
          'statusCode': response.statusCode,
          'detail': response.reasonPhrase ?? response.body,
        },
      );
    }
  }

  void close() {
    _client.close();
  }

  RegExp _compileRegex(String expression) {
    try {
      return RegExp(expression, caseSensitive: false);
    } catch (error) {
      throw AppException(
        AppExceptionCode.githubAssetRegexInvalid,
        values: <String, Object?>{'detail': error.toString()},
      );
    }
  }

  bool _isTruthy(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final text = value?.toString().toLowerCase().trim();
    return text == '1' || text == 'true';
  }
}
