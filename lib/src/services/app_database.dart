import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/managed_app.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static const String _defaultInstallDirKey = 'default_install_base_dir';
  static const String _githubTokenKey = 'github_token';
  static const String _preferredLocaleKey = 'preferred_locale';

  Database? _database;

  Future<void> initialize() async {
    await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    if (_database != null) {
      return _database!;
    }

    if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String databasePath;
    try {
      final supportDirectory = await getApplicationSupportDirectory();
      await supportDirectory.create(recursive: true);
      databasePath = p.join(supportDirectory.path, 'zup.db');
    } on MissingPluginException {
      databasePath = inMemoryDatabasePath;
    }

    _database = await openDatabase(
      databasePath,
      version: 3,
      onCreate: (db, version) async {
        await _createAppsTable(db);
        await _createSettingsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _safeAddColumn(db, 'apps', 'icon_path TEXT');
          await _safeAddColumn(db, 'apps', 'launch_exe_path TEXT');
          await _createSettingsTable(db);
        }
        if (oldVersion < 3) {
          await _safeAddColumn(
            db,
            'apps',
            'include_prerelease INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );

    return _database!;
  }

  Future<void> _createAppsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE apps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        repo_url TEXT NOT NULL UNIQUE,
        owner TEXT NOT NULL,
        repo TEXT NOT NULL,
        asset_regex TEXT NOT NULL,
        include_prerelease INTEGER NOT NULL DEFAULT 0,
        install_dir TEXT NOT NULL,
        installed_version TEXT,
        asset_name TEXT,
        icon_path TEXT,
        launch_exe_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSettingsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _safeAddColumn(
    Database db,
    String tableName,
    String definition,
  ) async {
    try {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $definition');
    } on DatabaseException catch (error) {
      if (error.toString().contains('duplicate column name')) {
        return;
      }
      rethrow;
    }
  }

  Future<List<ManagedApp>> listApps() async {
    final db = await _openDatabase();
    final rows = await db.query(
      'apps',
      orderBy: 'repo COLLATE NOCASE ASC, owner COLLATE NOCASE ASC, id ASC',
    );
    return rows.map(ManagedApp.fromMap).toList(growable: false);
  }

  Future<ManagedApp?> findAppById(int id) async {
    final db = await _openDatabase();
    final rows = await db.query('apps', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) {
      return null;
    }
    return ManagedApp.fromMap(rows.first);
  }

  Future<void> addApp(ManagedAppDraft draft) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final db = await _openDatabase();
    await db.insert('apps', {
      'repo_url': draft.repoUrl,
      'owner': draft.owner,
      'repo': draft.repo,
      'asset_regex': draft.assetRegex,
      'include_prerelease': draft.includePrerelease ? 1 : 0,
      'install_dir': draft.installDir,
      'installed_version': null,
      'asset_name': null,
      'icon_path': null,
      'launch_exe_path': null,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> updateApp(int id, ManagedAppDraft draft) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final db = await _openDatabase();
    await db.update(
      'apps',
      {
        'repo_url': draft.repoUrl,
        'owner': draft.owner,
        'repo': draft.repo,
        'asset_regex': draft.assetRegex,
        'include_prerelease': draft.includePrerelease ? 1 : 0,
        'install_dir': draft.installDir,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateInstalledVersion(
    int id, {
    required String version,
    required String assetName,
    String? iconPath,
    String? launchExePath,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final db = await _openDatabase();
    await db.update(
      'apps',
      {
        'installed_version': version,
        'asset_name': assetName,
        'icon_path': iconPath,
        'launch_exe_path': launchExePath,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteApp(int id) async {
    final db = await _openDatabase();
    await db.delete('apps', where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getDefaultInstallBaseDir() async {
    return _readSetting(_defaultInstallDirKey);
  }

  Future<void> setDefaultInstallBaseDir(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      await _deleteSetting(_defaultInstallDirKey);
      return;
    }
    await _writeSetting(_defaultInstallDirKey, normalized);
  }

  Future<String?> getGitHubToken() async {
    return _readSetting(_githubTokenKey);
  }

  Future<void> setGitHubToken(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      await _deleteSetting(_githubTokenKey);
      return;
    }
    await _writeSetting(_githubTokenKey, normalized);
  }

  Future<String?> getPreferredLocaleCode() async {
    return _readSetting(_preferredLocaleKey);
  }

  Future<void> setPreferredLocaleCode(String? value) async {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      await _deleteSetting(_preferredLocaleKey);
      return;
    }
    await _writeSetting(_preferredLocaleKey, normalized);
  }

  Future<void> _writeSetting(String key, String value) async {
    final db = await _openDatabase();
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> _readSetting(String key) async {
    final db = await _openDatabase();
    final rows = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final raw = rows.first['value']?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw;
  }

  Future<void> _deleteSetting(String key) async {
    final db = await _openDatabase();
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }
}
