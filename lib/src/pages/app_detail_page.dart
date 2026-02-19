import 'package:flutter/material.dart';

import '../models/managed_app.dart';
import '../services/app_database.dart';
import '../services/github_release_client.dart';
import '../services/zip_installer.dart';
import '../utils/date_time_format.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_editor_dialog.dart';
import '../widgets/atmosphere.dart';

class AppDetailPage extends StatefulWidget {
  const AppDetailPage({
    super.key,
    required this.app,
    required this.defaultInstallBaseDir,
  });

  final ManagedApp app;
  final String? defaultInstallBaseDir;

  @override
  State<AppDetailPage> createState() => _AppDetailPageState();
}

class _AppDetailPageState extends State<AppDetailPage> {
  final AppDatabase _database = AppDatabase.instance;
  final GitHubReleaseClient _gitHubClient = GitHubReleaseClient();
  final ZipInstaller _installer = ZipInstaller();

  late ManagedApp _app;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _app = widget.app;
  }

  @override
  void dispose() {
    _gitHubClient.close();
    _installer.close();
    super.dispose();
  }

  Future<void> _refreshApp() async {
    final refreshed = await _database.findAppById(_app.id);
    if (!mounted) {
      return;
    }
    if (refreshed == null) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _app = refreshed;
    });
  }

  Future<void> _withBusy(Future<void> Function() task) async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
    });

    try {
      await task();
    } catch (error) {
      _showSnackBar(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _checkLatestRelease() async {
    await _withBusy(() async {
      final release = await _gitHubClient.fetchLatestRelease(_app);
      if (!mounted) {
        return;
      }
      final current = _app.installedVersion ?? '未インストール';

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A2C45),
            title: Text('${_app.owner}/${_app.repo}'),
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
          );
        },
      );
    });
  }

  Future<void> _installOrUpdate() async {
    await _withBusy(() async {
      final release = await _gitHubClient.fetchLatestRelease(_app);
      final result = await _installer.install(
        installDirectory: _app.installDir,
        asset: release.selectedAsset,
      );
      await _database.updateInstalledVersion(
        _app.id,
        version: release.version,
        assetName: release.selectedAsset.name,
        iconPath: result.iconPath,
        launchExePath: result.launchExePath,
      );
      await _refreshApp();
      _showSnackBar('${_app.owner}/${_app.repo} を ${release.version} に更新しました。');
    });
  }

  Future<void> _openEditor() async {
    final draft = await showDialog<ManagedAppDraft>(
      context: context,
      builder: (_) => AppEditorDialog(
        existing: _app,
        defaultInstallBaseDir: widget.defaultInstallBaseDir,
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    await _withBusy(() async {
      await _database.updateApp(_app.id, draft);
      await _refreshApp();
      _showSnackBar('登録を更新しました。');
    });
  }

  Future<void> _deleteApp() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2C45),
          title: const Text('登録を削除'),
          content: Text('${_app.owner}/${_app.repo} を一覧から削除しますか？'),
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
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _withBusy(() async {
      await _database.deleteApp(_app.id);
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    });
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
    final installed = _app.installedVersion ?? '未インストール';

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
            const Atmosphere(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'アプリ詳細',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppAvatar(iconPath: _app.iconPath, size: 72),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _app.displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: const Color(0xFFFFE3BF),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'by ${_app.owner}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      installed,
                                      style: const TextStyle(
                                        color: Color(0xFFB8FFE9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '最終更新: ${formatDateTimeLocal(_app.updatedAt)}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.66,
                                        ),
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_busy)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _busy ? null : _checkLatestRelease,
                              icon: const Icon(Icons.search),
                              label: const Text('Check latest'),
                            ),
                            FilledButton.icon(
                              onPressed: _busy ? null : _installOrUpdate,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7A35),
                                foregroundColor: const Color(0xFF09111E),
                              ),
                              icon: const Icon(Icons.download),
                              label: Text(
                                _app.installedVersion == null
                                    ? 'Install'
                                    : 'Update',
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _busy ? null : _openEditor,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: _busy ? null : _deleteApp,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFFFB9C0),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailRow(
                                label: 'GitHub URL',
                                value: _app.repoUrl,
                              ),
                              _DetailRow(
                                label: 'Owner/Repo',
                                value: '${_app.owner}/${_app.repo}',
                              ),
                              _DetailRow(
                                label: 'Asset Regex',
                                value: _app.assetRegex,
                              ),
                              _DetailRow(
                                label: 'Install Dir',
                                value: _app.installDir,
                              ),
                              _DetailRow(
                                label: 'Installed Version',
                                value: _app.installedVersion ?? '未インストール',
                              ),
                              _DetailRow(
                                label: 'Last zip',
                                value: _app.assetName ?? '-',
                              ),
                              _DetailRow(
                                label: 'Launch EXE',
                                value: _app.launchExePath ?? '-',
                              ),
                              _DetailRow(
                                label: 'Icon Path',
                                value: _app.iconPath ?? '-',
                              ),
                              _DetailRow(
                                label: 'Updated',
                                value: formatDateTimeLocal(_app.updatedAt),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x7F102640),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x80FFFFFF)),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.66)),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
