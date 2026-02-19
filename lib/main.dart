import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.initialize();
  runApp(const ZupApp());
}

class ZupApp extends StatelessWidget {
  const ZupApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.ibmPlexSansTextTheme(base.textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zup',
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: textTheme,
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFFFF7A35),
          secondary: const Color(0xFF42E2B8),
          surface: const Color(0xFF10243B),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase _database = AppDatabase.instance;
  final GitHubReleaseClient _gitHubClient = GitHubReleaseClient();
  final ZipInstaller _installer = ZipInstaller();

  List<ManagedApp> _apps = const <ManagedApp>[];
  final Set<int> _busyAppIds = <int>{};
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _refreshApps(withLoader: true);
  }

  @override
  void dispose() {
    _gitHubClient.close();
    _installer.close();
    super.dispose();
  }

  Future<void> _refreshApps({bool withLoader = false}) async {
    if (withLoader && mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final items = await _database.listApps();
      if (!mounted) {
        return;
      }
      setState(() {
        _apps = items;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = '読み込みに失敗しました: $error';
      });
    } finally {
      if (withLoader && mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openEditor({ManagedApp? existing}) async {
    final draft = await showDialog<ManagedAppDraft>(
      context: context,
      builder: (_) => AppEditorDialog(existing: existing),
    );

    if (!mounted || draft == null) {
      return;
    }

    try {
      if (existing == null) {
        await _database.addApp(draft);
      } else {
        await _database.updateApp(existing.id, draft);
      }
      await _refreshApps();
      if (!mounted) {
        return;
      }
      _showSnackBar(existing == null ? 'ソースを追加しました。' : 'ソースを更新しました。');
    } on DatabaseException catch (error) {
      final isDuplicate = error.toString().contains('UNIQUE constraint failed');
      _showSnackBar(
        isDuplicate ? '同じGitHub URLはすでに登録されています。' : '保存に失敗しました: $error',
        isError: true,
      );
    } catch (error) {
      _showSnackBar('保存に失敗しました: $error', isError: true);
    }
  }

  Future<void> _deleteApp(ManagedApp app) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2C45),
        title: const Text('登録を削除'),
        content: Text('${app.owner}/${app.repo} を一覧から削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFCF3A5B),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _database.deleteApp(app.id);
      await _refreshApps();
      if (!mounted) {
        return;
      }
      _showSnackBar('削除しました。');
    } catch (error) {
      _showSnackBar('削除に失敗しました: $error', isError: true);
    }
  }

  Future<void> _checkLatestRelease(ManagedApp app) async {
    await _runBusy(app.id, () async {
      final release = await _gitHubClient.fetchLatestRelease(app);
      if (!mounted) {
        return;
      }
      final current = app.installedVersion ?? '未インストール';
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A2C45),
          title: Text('${app.owner}/${app.repo}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('現在: $current'),
              const SizedBox(height: 8),
              Text('最新: ${release.version}'),
              const SizedBox(height: 8),
              Text('選択zip: ${release.selectedAsset.name}'),
              if (release.matchedAssetCount > 1) ...[
                const SizedBox(height: 8),
                Text('一致候補: ${release.matchedAssetCount}件'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _installOrUpdate(ManagedApp app) async {
    await _runBusy(app.id, () async {
      final release = await _gitHubClient.fetchLatestRelease(app);
      await _installer.install(
        installDirectory: app.installDir,
        asset: release.selectedAsset,
      );
      await _database.updateInstalledVersion(
        app.id,
        version: release.version,
        assetName: release.selectedAsset.name,
      );
      await _refreshApps();
      if (!mounted) {
        return;
      }
      _showSnackBar('${app.owner}/${app.repo} を ${release.version} に更新しました。');
    });
  }

  Future<void> _runBusy(int appId, Future<void> Function() task) async {
    if (_busyAppIds.contains(appId) || !mounted) {
      return;
    }
    setState(() {
      _busyAppIds.add(appId);
    });

    try {
      await task();
    } catch (error) {
      _showSnackBar(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _busyAppIds.remove(appId);
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? const Color(0xFF9E2A2B)
            : const Color(0xFF214E6A),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1524), Color(0xFF143C57), Color(0xFF7A3324)],
          ),
        ),
        child: Stack(
          children: [
            const _Atmosphere(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    _TopBar(
                      onAdd: _openEditor,
                      onRefresh: () => _refreshApps(withLoader: true),
                    ),
                    const SizedBox(height: 20),
                    if (_loadError != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0x55D73A49),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _loadError!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    if (_loadError != null) const SizedBox(height: 12),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_apps.isEmpty) {
      return const Center(child: _EmptyState());
    }

    return ListView.separated(
      itemCount: _apps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final app = _apps[index];
        return AppCard(
          app: app,
          busy: _busyAppIds.contains(app.id),
          onCheck: () => _checkLatestRelease(app),
          onInstall: () => _installOrUpdate(app),
          onEdit: () => _openEditor(existing: app),
          onDelete: () => _deleteApp(app),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onAdd, required this.onRefresh});

  final VoidCallback onAdd;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 900;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ZUP',
          style: GoogleFonts.bebasNeue(
            fontSize: 68,
            letterSpacing: 2,
            color: const Color(0xFFFFC17A),
            height: 0.9,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'GitHub Release ZIP Installer',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: onRefresh,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0x80FFFFFF)),
            backgroundColor: const Color(0x22102C45),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('Reload'),
        ),
        FilledButton.icon(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF7A35),
            foregroundColor: const Color(0xFF09111E),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add URL'),
        ),
      ],
    );

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 12), actions],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        actions,
      ],
    );
  }
}

class _Atmosphere extends StatelessWidget {
  const _Atmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: -120,
            top: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x40FFA15C), Color(0x0014314A)],
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            bottom: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x3065FFE8), Color(0x00080F1D)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0x66122438),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x90FFFFFF), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 44, color: Colors.white),
          const SizedBox(height: 14),
          Text(
            '登録されたアプリはまだありません',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'GitHubのリポジトリURLを追加すると、\nlatest release から zip を取得して展開できます。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.app,
    required this.busy,
    required this.onCheck,
    required this.onInstall,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ManagedApp app;
  final bool busy;
  final VoidCallback onCheck;
  final VoidCallback onInstall;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final installed = app.installedVersion ?? '未インストール';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x7F102640),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x80FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF42E2B8).withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.apps, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${app.owner}/${app.repo}',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFE3BF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.repoUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaPill(
                  icon: Icons.tag,
                  label: 'Installed',
                  value: installed,
                ),
                _MetaPill(
                  icon: Icons.filter_alt_outlined,
                  label: 'Regex',
                  value: app.assetRegex,
                ),
                if (app.assetName != null && app.assetName!.isNotEmpty)
                  _MetaPill(
                    icon: Icons.archive_outlined,
                    label: 'Last zip',
                    value: app.assetName!,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Install dir: ${app.installDir}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : onCheck,
                  icon: const Icon(Icons.search),
                  label: const Text('Check latest'),
                ),
                FilledButton.icon(
                  onPressed: busy ? null : onInstall,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A35),
                    foregroundColor: const Color(0xFF09111E),
                  ),
                  icon: const Icon(Icons.download),
                  label: Text(
                    app.installedVersion == null ? 'Install' : 'Update',
                  ),
                ),
                TextButton.icon(
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: busy ? null : onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFB9C0),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x66253D57),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF84FFE2)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label: $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppEditorDialog extends StatefulWidget {
  const AppEditorDialog({super.key, this.existing});

  final ManagedApp? existing;

  @override
  State<AppEditorDialog> createState() => _AppEditorDialogState();
}

class _AppEditorDialogState extends State<AppEditorDialog> {
  late final TextEditingController _urlController;
  late final TextEditingController _regexController;
  late final TextEditingController _installDirController;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: widget.existing?.repoUrl ?? '',
    );
    _regexController = TextEditingController(
      text: widget.existing?.assetRegex ?? r'.*\.zip$',
    );
    _installDirController = TextEditingController(
      text: widget.existing?.installDir ?? '',
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _regexController.dispose();
    _installDirController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final selected = await getDirectoryPath(
      initialDirectory: _installDirController.text.isEmpty
          ? null
          : _installDirController.text,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _installDirController.value = TextEditingValue(
        text: selected,
        selection: TextSelection.collapsed(offset: selected.length),
      );
    });
  }

  void _submit() {
    final url = _urlController.text.trim();
    final regex = _regexController.text.trim();
    final installDir = _installDirController.text.trim();

    try {
      if (url.isEmpty) {
        throw const FormatException('GitHub URLを入力してください。');
      }
      if (regex.isEmpty) {
        throw const FormatException('zipフィルタ用の正規表現を入力してください。');
      }
      if (installDir.isEmpty) {
        throw const FormatException('インストール先ディレクトリを入力してください。');
      }

      final repo = GitHubRepoRef.fromUrl(url);
      RegExp(regex, caseSensitive: false);

      Navigator.pop(
        context,
        ManagedAppDraft(
          repoUrl: repo.canonicalUrl,
          owner: repo.owner,
          repo: repo.repo,
          assetRegex: regex,
          installDir: installDir,
        ),
      );
    } catch (error) {
      setState(() {
        _validationMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      backgroundColor: const Color(0xFF182B44),
      title: Text(isEdit ? '登録を編集' : 'GitHub URLを追加'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'GitHub URL',
                  hintText: 'https://github.com/owner/repo',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _regexController,
                decoration: const InputDecoration(
                  labelText: 'zip フィルタ正規表現',
                  hintText: r'.*(windows|win64).*\.zip$',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _installDirController,
                      decoration: const InputDecoration(
                        labelText: 'インストール先ディレクトリ',
                        hintText: r'C:\Tools\my-app',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _pickDirectory,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Browse'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '注: 対象は latest release の zip アセットのみです。',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
              if (_validationMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _validationMessage!,
                  style: const TextStyle(color: Color(0xFFFFB2AE)),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF7A35),
            foregroundColor: const Color(0xFF09111E),
          ),
          icon: const Icon(Icons.save),
          label: Text(isEdit ? '更新' : '追加'),
        ),
      ],
    );
  }
}

class ManagedAppDraft {
  const ManagedAppDraft({
    required this.repoUrl,
    required this.owner,
    required this.repo,
    required this.assetRegex,
    required this.installDir,
  });

  final String repoUrl;
  final String owner;
  final String repo;
  final String assetRegex;
  final String installDir;
}

class ManagedApp {
  const ManagedApp({
    required this.id,
    required this.repoUrl,
    required this.owner,
    required this.repo,
    required this.assetRegex,
    required this.installDir,
    required this.installedVersion,
    required this.assetName,
  });

  final int id;
  final String repoUrl;
  final String owner;
  final String repo;
  final String assetRegex;
  final String installDir;
  final String? installedVersion;
  final String? assetName;

  factory ManagedApp.fromMap(Map<String, Object?> map) {
    return ManagedApp(
      id: map['id'] as int,
      repoUrl: map['repo_url'] as String,
      owner: map['owner'] as String,
      repo: map['repo'] as String,
      assetRegex: map['asset_regex'] as String,
      installDir: map['install_dir'] as String,
      installedVersion: map['installed_version'] as String?,
      assetName: map['asset_name'] as String?,
    );
  }
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE apps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            repo_url TEXT NOT NULL UNIQUE,
            owner TEXT NOT NULL,
            repo TEXT NOT NULL,
            asset_regex TEXT NOT NULL,
            install_dir TEXT NOT NULL,
            installed_version TEXT,
            asset_name TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<List<ManagedApp>> listApps() async {
    final db = await _openDatabase();
    final rows = await db.query('apps', orderBy: 'updated_at DESC, id DESC');
    return rows.map(ManagedApp.fromMap).toList(growable: false);
  }

  Future<void> addApp(ManagedAppDraft draft) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final db = await _openDatabase();
    await db.insert('apps', {
      'repo_url': draft.repoUrl,
      'owner': draft.owner,
      'repo': draft.repo,
      'asset_regex': draft.assetRegex,
      'install_dir': draft.installDir,
      'installed_version': null,
      'asset_name': null,
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
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final db = await _openDatabase();
    await db.update(
      'apps',
      {
        'installed_version': version,
        'asset_name': assetName,
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
}

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

class ReleaseAssetInfo {
  const ReleaseAssetInfo({
    required this.name,
    required this.downloadUrl,
    required this.sizeBytes,
  });

  final String name;
  final String downloadUrl;
  final int? sizeBytes;
}

class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.publishedAt,
    required this.selectedAsset,
    required this.matchedAssetCount,
  });

  final String version;
  final DateTime? publishedAt;
  final ReleaseAssetInfo selectedAsset;
  final int matchedAssetCount;
}

class GitHubReleaseClient {
  final http.Client _client = http.Client();

  Future<ReleaseInfo> fetchLatestRelease(ManagedApp app) async {
    final uri = Uri.https(
      'api.github.com',
      '/repos/${app.owner}/${app.repo}/releases/latest',
    );
    final response = await _client.get(
      uri,
      headers: const {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'zup-flutter-client',
      },
    );

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
      final url = map['browser_download_url']?.toString() ?? '';
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

class ZipInstaller {
  final http.Client _client = http.Client();

  Future<void> install({
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

    for (final entry in archive) {
      if (entry.name.isEmpty) {
        continue;
      }
      final outputPath = _safeOutputPath(targetRoot, entry.name);

      if (entry.isFile) {
        final outputFile = File(outputPath);
        await outputFile.parent.create(recursive: true);
        await outputFile.writeAsBytes(entry.content, flush: true);
      } else {
        await Directory(outputPath).create(recursive: true);
      }
    }
  }

  void close() {
    _client.close();
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
}
