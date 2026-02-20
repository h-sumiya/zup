import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zup/l10n/app_localizations.dart';

import '../i18n/localized_error.dart';
import '../models/managed_app.dart';
import '../services/app_database.dart';
import '../services/github_release_client.dart';
import '../services/zip_installer.dart';
import '../utils/date_time_format.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_editor_dialog.dart';
import '../widgets/atmosphere.dart';

enum _DeleteMode { registrationOnly, registrationAndFolder }

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
  late final GitHubReleaseClient _gitHubClient;
  late final ZipInstaller _installer;

  late ManagedApp _app;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _app = widget.app;
    _gitHubClient = GitHubReleaseClient(
      tokenProvider: _database.getGitHubToken,
    );
    _installer = ZipInstaller(tokenProvider: _database.getGitHubToken);
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

  Future<void> _withBusy(
    Future<void> Function() task, {
    String? actionLabel,
  }) async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
    });

    try {
      await task();
    } catch (error) {
      _showSnackBar(
        _formatTaskError(error, actionLabel: actionLabel),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  String _formatTaskError(Object error, {String? actionLabel}) {
    final l10n = AppLocalizations.of(context)!;
    if (_isRunningAppFileLockError(error)) {
      if (actionLabel == null || actionLabel.isEmpty) {
        return l10n.detailErrorFileOperationFailedAppRunning;
      }
      return l10n.detailErrorActionFailedAppRunning(actionLabel);
    }

    final detail = _normalizeErrorMessage(error);
    if (actionLabel == null || actionLabel.isEmpty) {
      return detail;
    }
    return l10n.errorActionFailed(actionLabel, detail);
  }

  String _normalizeErrorMessage(Object error) {
    return localizeErrorMessage(context, error);
  }

  bool _isRunningAppFileLockError(Object error) {
    if (error is FileSystemException) {
      final code = error.osError?.errorCode;
      if (code == 5 || code == 16 || code == 26 || code == 32 || code == 33) {
        return true;
      }
      final osMessage = error.osError?.message ?? '';
      final message = '$osMessage ${error.message}';
      if (_containsBusyText(message)) {
        return true;
      }
    }
    return _containsBusyText(error.toString());
  }

  bool _containsBusyText(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('being used by another process') ||
        normalized.contains('process cannot access the file') ||
        normalized.contains('text file busy') ||
        normalized.contains('device or resource busy') ||
        normalized.contains('resource busy') ||
        normalized.contains('used by another process');
  }

  Future<void> _checkLatestRelease() async {
    await _withBusy(() async {
      final l10n = AppLocalizations.of(context)!;
      final release = await _gitHubClient.fetchLatestRelease(_app);
      if (!mounted) {
        return;
      }
      final current = _app.installedVersion ?? l10n.commonNotInstalled;

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
                Text(l10n.detailCurrentVersion(current)),
                const SizedBox(height: 8),
                Text(l10n.detailLatestVersion(release.version)),
                const SizedBox(height: 8),
                Text(l10n.detailSelectedZip(release.selectedAsset.name)),
                if (release.matchedAssetCount > 1) ...[
                  const SizedBox(height: 8),
                  Text(l10n.detailMatchedAssetCount(release.matchedAssetCount)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonClose),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _installOrUpdate() async {
    await _withBusy(
      () async {
        final l10n = AppLocalizations.of(context)!;
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
        _showSnackBar(
          l10n.detailUpdatedToVersion(
            '${_app.owner}/${_app.repo}',
            release.version,
          ),
        );
      },
      actionLabel: _app.installedVersion == null
          ? _actionInstall
          : _actionUpdate,
    );
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
      final l10n = AppLocalizations.of(context)!;
      await _database.updateApp(_app.id, draft);
      await _refreshApp();
      _showSnackBar(l10n.detailRegistrationUpdated);
    }, actionLabel: _actionEdit);
  }

  Future<void> _openInstallDirectory() async {
    await _withBusy(() async {
      final l10n = AppLocalizations.of(context)!;
      final directory = Directory(_app.installDir);
      if (!await directory.exists()) {
        throw Exception(l10n.detailInstallDirNotFound(_app.installDir));
      }
      await _openDirectoryInExplorer(directory.absolute.path);
    }, actionLabel: _actionOpenLocation);
  }

  Future<void> _openDirectoryInExplorer(String path) async {
    final l10n = AppLocalizations.of(context)!;
    if (Platform.isWindows) {
      final result = await Process.run('explorer', [path]);
      final stderr = (result.stderr ?? '').toString().trim();
      // Windowsのexplorerは成功時でもexitCode=1を返すことがある。
      if (result.exitCode == 0 || (result.exitCode == 1 && stderr.isEmpty)) {
        return;
      }
      final detail = stderr.isEmpty
          ? l10n.commonExitCode(result.exitCode)
          : stderr;
      throw Exception(l10n.detailFailedToOpenExplorer(detail));
    }

    ProcessResult result;
    if (Platform.isMacOS) {
      result = await Process.run('open', [path]);
    } else if (Platform.isLinux) {
      result = await Process.run('xdg-open', [path]);
    } else {
      throw UnsupportedError(l10n.detailUnsupportedOpenLocation);
    }

    if (result.exitCode != 0) {
      final stderr = (result.stderr ?? '').toString().trim();
      final detail = stderr.isEmpty
          ? l10n.commonExitCode(result.exitCode)
          : stderr;
      throw Exception(l10n.detailFailedToOpenExplorer(detail));
    }
  }

  Future<void> _deleteInstallDirectoryIfExists() async {
    final directory = Directory(_app.installDir);
    if (!await directory.exists()) {
      return;
    }
    await directory.delete(recursive: true);
  }

  Future<_DeleteMode?> _askDeleteMode() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<_DeleteMode>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2C45),
          title: Text(l10n.detailDeleteDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.detailDeleteTarget('${_app.owner}/${_app.repo}')),
              const SizedBox(height: 8),
              Text(l10n.detailDeleteDialogDescription),
              const SizedBox(height: 8),
              Text(
                l10n.detailInstallDestination(_app.installDir),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.76)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel),
            ),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pop(context, _DeleteMode.registrationOnly),
              child: Text(l10n.detailDeleteRegistrationOnly),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFCF3A5B),
              ),
              onPressed: () =>
                  Navigator.pop(context, _DeleteMode.registrationAndFolder),
              child: Text(l10n.detailDeleteRegistrationAndFolder),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteApp() async {
    final mode = await _askDeleteMode();
    if (mode == null || !mounted) {
      return;
    }

    final deleteFolder = mode == _DeleteMode.registrationAndFolder;

    await _withBusy(() async {
      if (deleteFolder) {
        await _deleteInstallDirectoryIfExists();
      }
      await _database.deleteApp(_app.id);
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    }, actionLabel: deleteFolder ? _actionDeleteFolder : _actionDelete);
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
    final l10n = AppLocalizations.of(context)!;
    final installed = _app.installedVersion ?? l10n.commonNotInstalled;

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
                              l10n.detailPageTitle,
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
                                      l10n.commonByOwner(_app.owner),
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
                                      l10n.detailUpdatedAt(
                                        formatDateTimeLocal(_app.updatedAt),
                                      ),
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
                              label: Text(l10n.detailCheckLatest),
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
                                    ? l10n.commonInstall
                                    : l10n.commonUpdate,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _busy ? null : _openInstallDirectory,
                              icon: const Icon(Icons.folder_open),
                              label: Text(l10n.detailOpenLocation),
                            ),
                            TextButton.icon(
                              onPressed: _busy ? null : _openEditor,
                              icon: const Icon(Icons.edit),
                              label: Text(l10n.commonEdit),
                            ),
                            TextButton.icon(
                              onPressed: _busy ? null : _deleteApp,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFFFB9C0),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: Text(l10n.commonDelete),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailRow(
                                label: l10n.detailFieldGitHubUrl,
                                value: _app.repoUrl,
                              ),
                              _DetailRow(
                                label: l10n.detailFieldOwnerRepo,
                                value: '${_app.owner}/${_app.repo}',
                              ),
                              _DetailRow(
                                label: l10n.detailFieldAssetRegex,
                                value: _app.assetRegex,
                              ),
                              _DetailRow(
                                label: l10n.detailFieldIncludePrerelease,
                                value: _app.includePrerelease
                                    ? l10n.commonEnabled
                                    : l10n.commonDisabled,
                              ),
                              _DetailRow(
                                label: l10n.detailFieldInstallDir,
                                value: _app.installDir,
                              ),
                              _DetailRow(
                                label: l10n.detailFieldInstalledVersion,
                                value:
                                    _app.installedVersion ??
                                    l10n.commonNotInstalled,
                              ),
                              _DetailRow(
                                label: l10n.detailFieldLastZip,
                                value: _app.assetName ?? '-',
                              ),
                              _DetailRow(
                                label: l10n.detailFieldLaunchExe,
                                value: _app.launchExePath ?? '-',
                              ),
                              _DetailRow(
                                label: l10n.detailFieldIconPath,
                                value: _app.iconPath ?? '-',
                              ),
                              _DetailRow(
                                label: l10n.detailFieldUpdated,
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

  String get _actionInstall => AppLocalizations.of(context)!.commonInstall;

  String get _actionUpdate => AppLocalizations.of(context)!.commonUpdate;

  String get _actionEdit => AppLocalizations.of(context)!.commonEdit;

  String get _actionOpenLocation =>
      AppLocalizations.of(context)!.detailOpenLocation;

  String get _actionDelete => AppLocalizations.of(context)!.commonDelete;

  String get _actionDeleteFolder =>
      AppLocalizations.of(context)!.detailDeleteWithFolderAction;
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
