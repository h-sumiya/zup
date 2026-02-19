import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../models/release_info.dart';

class InstallResult {
  const InstallResult({required this.iconPath, required this.launchExePath});

  final String? iconPath;
  final String? launchExePath;
}

class ZipInstaller {
  final http.Client _client = http.Client();

  Future<InstallResult> install({
    required String installDirectory,
    required ReleaseAssetInfo asset,
  }) async {
    final targetDirectory = Directory(installDirectory);
    await targetDirectory.create(recursive: true);
    final targetRoot = p.normalize(p.absolute(targetDirectory.path));

    final response = await _client.get(
      Uri.parse(asset.downloadUrl),
      headers: const {'User-Agent': 'zup-flutter-client'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'zipのダウンロードに失敗しました (${response.statusCode}): ${asset.name}',
      );
    }

    final archive = ZipDecoder().decodeBytes(response.bodyBytes, verify: true);
    if (archive.isEmpty) {
      throw const FormatException('zipが空です。');
    }

    final writtenFiles = <String>[];

    for (final entry in archive) {
      if (entry.name.isEmpty) {
        continue;
      }
      final outputPath = _safeOutputPath(targetRoot, entry.name);

      if (entry.isFile) {
        final outputFile = File(outputPath);
        await outputFile.parent.create(recursive: true);
        await outputFile.writeAsBytes(entry.content, flush: true);
        writtenFiles.add(outputPath);
      } else {
        await Directory(outputPath).create(recursive: true);
      }
    }

    final launchExePath = _selectLaunchExecutable(targetRoot, writtenFiles);
    final iconPath = await _resolveIconPath(
      targetRoot,
      writtenFiles,
      launchExePath,
    );

    return InstallResult(iconPath: iconPath, launchExePath: launchExePath);
  }

  void close() {
    _client.close();
  }

  Future<String?> _resolveIconPath(
    String targetRoot,
    List<String> files,
    String? launchExePath,
  ) async {
    final iconCandidates =
        files
            .where(
              (filePath) => _imageExtensions.contains(
                p.extension(filePath).toLowerCase(),
              ),
            )
            .toList(growable: false)
          ..sort((a, b) {
            final depthDiff = _pathDepth(
              targetRoot,
              a,
            ).compareTo(_pathDepth(targetRoot, b));
            if (depthDiff != 0) {
              return depthDiff;
            }
            final nameDiff = p
                .basenameWithoutExtension(a)
                .length
                .compareTo(p.basenameWithoutExtension(b).length);
            if (nameDiff != 0) {
              return nameDiff;
            }
            return a.compareTo(b);
          });

    if (iconCandidates.isNotEmpty) {
      return iconCandidates.first;
    }

    if (Platform.isWindows && launchExePath != null) {
      return _extractWindowsExeIcon(targetRoot, launchExePath);
    }

    return null;
  }

  String? _selectLaunchExecutable(String targetRoot, List<String> files) {
    final executableCandidates =
        files
            .where((filePath) => p.extension(filePath).toLowerCase() == '.exe')
            .toList(growable: false)
          ..sort((a, b) {
            final depthDiff = _pathDepth(
              targetRoot,
              a,
            ).compareTo(_pathDepth(targetRoot, b));
            if (depthDiff != 0) {
              return depthDiff;
            }
            final nameDiff = p
                .basenameWithoutExtension(a)
                .length
                .compareTo(p.basenameWithoutExtension(b).length);
            if (nameDiff != 0) {
              return nameDiff;
            }
            return a.compareTo(b);
          });

    if (executableCandidates.isEmpty) {
      return null;
    }
    return executableCandidates.first;
  }

  int _pathDepth(String root, String path) {
    final relative = p.relative(path, from: root).replaceAll('\\', '/');
    if (relative.isEmpty || relative == '.') {
      return 0;
    }
    return relative.split('/').length;
  }

  Future<String?> _extractWindowsExeIcon(
    String targetRoot,
    String exePath,
  ) async {
    final outputDirectory = Directory(p.join(targetRoot, '.zup'));
    await outputDirectory.create(recursive: true);
    final outputPath = p.join(outputDirectory.path, 'app_icon.png');

    final escapedExe = _escapePowerShellSingleQuoted(exePath);
    final escapedOutput = _escapePowerShellSingleQuoted(outputPath);

    final script =
        '''
Add-Type -AssemblyName System.Drawing
try {
  \$icon = [System.Drawing.Icon]::ExtractAssociatedIcon('$escapedExe')
  if (\$null -eq \$icon) {
    exit 2
  }
  \$bitmap = \$icon.ToBitmap()
  \$bitmap.Save('$escapedOutput', [System.Drawing.Imaging.ImageFormat]::Png)
  \$bitmap.Dispose()
  \$icon.Dispose()
  exit 0
} catch {
  exit 1
}
''';

    final result = await Process.run('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      script,
    ]);

    if (result.exitCode != 0) {
      return null;
    }

    if (await File(outputPath).exists()) {
      return outputPath;
    }
    return null;
  }

  String _escapePowerShellSingleQuoted(String input) {
    return input.replaceAll("'", "''");
  }

  String _safeOutputPath(String targetRoot, String rawEntryPath) {
    final normalized = p.normalize(rawEntryPath.replaceAll('\\', '/'));
    if (normalized == '.' || normalized.isEmpty) {
      return targetRoot;
    }
    if (p.isAbsolute(normalized) ||
        normalized == '..' ||
        normalized.startsWith('../') ||
        normalized.contains('/../')) {
      throw FormatException('zip内に不正なパスが含まれています: $rawEntryPath');
    }

    final resolved = p.normalize(p.absolute(p.join(targetRoot, normalized)));
    if (!p.isWithin(targetRoot, resolved) && resolved != targetRoot) {
      throw FormatException('zip内に不正なパスが含まれています: $rawEntryPath');
    }
    return resolved;
  }

  static const Set<String> _imageExtensions = <String>{
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
    '.bmp',
    '.gif',
  };
}
