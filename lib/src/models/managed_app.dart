class ManagedAppDraft {
  const ManagedAppDraft({
    required this.repoUrl,
    required this.owner,
    required this.repo,
    required this.assetRegex,
    required this.includePrerelease,
    required this.installDir,
  });

  final String repoUrl;
  final String owner;
  final String repo;
  final String assetRegex;
  final bool includePrerelease;
  final String installDir;
}

class ManagedApp {
  const ManagedApp({
    required this.id,
    required this.repoUrl,
    required this.owner,
    required this.repo,
    required this.assetRegex,
    required this.includePrerelease,
    required this.installDir,
    required this.installedVersion,
    required this.assetName,
    required this.iconPath,
    required this.launchExePath,
    required this.updatedAt,
  });

  final int id;
  final String repoUrl;
  final String owner;
  final String repo;
  final String assetRegex;
  final bool includePrerelease;
  final String installDir;
  final String? installedVersion;
  final String? assetName;
  final String? iconPath;
  final String? launchExePath;
  final DateTime updatedAt;

  String get displayName => repo;

  factory ManagedApp.fromMap(Map<String, Object?> map) {
    return ManagedApp(
      id: map['id'] as int,
      repoUrl: map['repo_url'] as String,
      owner: map['owner'] as String,
      repo: map['repo'] as String,
      assetRegex: map['asset_regex'] as String,
      includePrerelease: _readBool(map['include_prerelease']),
      installDir: map['install_dir'] as String,
      installedVersion: _readNullable(map['installed_version']),
      assetName: _readNullable(map['asset_name']),
      iconPath: _readNullable(map['icon_path']),
      launchExePath: _readNullable(map['launch_exe_path']),
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  static String? _readNullable(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static bool _readBool(Object? value) {
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
