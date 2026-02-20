import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:zup/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

import '../i18n/localized_error.dart';
import '../models/github_repo_ref.dart';
import '../models/managed_app.dart';

class AppEditorDialog extends StatefulWidget {
  const AppEditorDialog({super.key, this.existing, this.defaultInstallBaseDir});

  final ManagedApp? existing;
  final String? defaultInstallBaseDir;

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
      text: widget.existing?.installDir ?? widget.defaultInstallBaseDir ?? '',
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
          ? widget.defaultInstallBaseDir
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
    final l10n = AppLocalizations.of(context)!;
    final url = _urlController.text.trim();
    final regex = _regexController.text.trim();
    var installDir = _installDirController.text.trim();

    try {
      if (url.isEmpty) {
        throw FormatException(l10n.editorErrorGitHubUrlRequired);
      }
      if (regex.isEmpty) {
        throw FormatException(l10n.editorErrorZipRegexRequired);
      }

      final repo = GitHubRepoRef.fromUrl(url);
      RegExp(regex, caseSensitive: false);

      if (installDir.isEmpty) {
        final base = widget.defaultInstallBaseDir?.trim() ?? '';
        if (base.isEmpty) {
          throw FormatException(l10n.editorErrorInstallDirRequired);
        }
        installDir = p.join(base, repo.repo);
      } else if (widget.defaultInstallBaseDir != null &&
          installDir == widget.defaultInstallBaseDir!.trim()) {
        installDir = p.join(installDir, repo.repo);
      }

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
        _validationMessage = localizeErrorMessage(context, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.existing != null;

    return AlertDialog(
      backgroundColor: const Color(0xFF182B44),
      title: Text(isEdit ? l10n.editorTitleEdit : l10n.editorTitleAdd),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n.editorGitHubUrlLabel,
                  hintText: 'https://github.com/owner/repo',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _regexController,
                decoration: InputDecoration(
                  labelText: l10n.editorZipRegexLabel,
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
                      decoration: InputDecoration(
                        labelText: l10n.editorInstallDirLabel,
                        hintText: r'C:\Tools\my-app',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _pickDirectory,
                    icon: const Icon(Icons.folder_open),
                    label: Text(l10n.commonBrowse),
                  ),
                ],
              ),
              if (widget.defaultInstallBaseDir != null &&
                  widget.defaultInstallBaseDir!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.editorDefaultPathNotice(
                    widget.defaultInstallBaseDir!,
                    _urlPreviewRepo(),
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                l10n.editorLatestReleaseNote,
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
          child: Text(l10n.commonCancel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF7A35),
            foregroundColor: const Color(0xFF09111E),
          ),
          icon: const Icon(Icons.save),
          label: Text(isEdit ? l10n.commonUpdate : l10n.commonAdd),
        ),
      ],
    );
  }

  String _urlPreviewRepo() {
    try {
      final repo = GitHubRepoRef.fromUrl(_urlController.text);
      return repo.repo;
    } catch (_) {
      return 'app-name';
    }
  }
}
