import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:zup/l10n/app_localizations.dart';

import '../i18n/app_locale.dart';
import '../services/app_database.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.initialDefaultInstallDir,
    required this.initialGitHubToken,
    required this.initialLocaleCode,
  });

  final String? initialDefaultInstallDir;
  final String? initialGitHubToken;
  final String? initialLocaleCode;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppDatabase _database = AppDatabase.instance;
  late final TextEditingController _defaultInstallDirController;
  late final TextEditingController _gitHubTokenController;

  bool _saving = false;
  bool _obscureGitHubToken = true;
  String? _error;
  late String _selectedLanguageOption;

  static const String _languageOptionAuto = 'auto';

  @override
  void initState() {
    super.initState();
    _defaultInstallDirController = TextEditingController(
      text: widget.initialDefaultInstallDir ?? '',
    );
    _gitHubTokenController = TextEditingController(
      text: widget.initialGitHubToken ?? '',
    );
    _selectedLanguageOption =
        normalizeAppLocaleCode(widget.initialLocaleCode) ?? _languageOptionAuto;
  }

  @override
  void dispose() {
    _defaultInstallDirController.dispose();
    _gitHubTokenController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final selected = await getDirectoryPath(
      initialDirectory: _defaultInstallDirController.text.isEmpty
          ? null
          : _defaultInstallDirController.text,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _defaultInstallDirController.value = TextEditingValue(
        text: selected,
        selection: TextSelection.collapsed(offset: selected.length),
      );
    });
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _database.setDefaultInstallBaseDir(
        _defaultInstallDirController.text,
      );
      await _database.setGitHubToken(_gitHubTokenController.text);
      await _database.setPreferredLocaleCode(
        _selectedLanguageOption == _languageOptionAuto
            ? null
            : _selectedLanguageOption,
      );
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = l10n.errorSaveFailed(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguageSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsLanguageSectionDescription,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLanguageOption,
                  decoration: InputDecoration(
                    labelText: l10n.settingsLanguageLabel,
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: _languageOptionAuto,
                      child: Text(l10n.settingsLanguageAuto),
                    ),
                    DropdownMenuItem<String>(
                      value: 'ja',
                      child: Text(l10n.settingsLanguageJapanese),
                    ),
                    DropdownMenuItem<String>(
                      value: 'en',
                      child: Text(l10n.settingsLanguageEnglish),
                    ),
                    DropdownMenuItem<String>(
                      value: 'zh',
                      child: Text(l10n.settingsLanguageChinese),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedLanguageOption = value;
                          });
                        },
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.settingsDefaultInstallDirTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsDefaultInstallDirDescription,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _defaultInstallDirController,
                        decoration: InputDecoration(
                          labelText: l10n.settingsDefaultInstallDirExample,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickDirectory,
                      icon: const Icon(Icons.folder_open),
                      label: Text(l10n.commonBrowse),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.settingsGitHubTokenTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsGitHubTokenDescription,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _gitHubTokenController,
                  autocorrect: false,
                  enableSuggestions: false,
                  obscureText: _obscureGitHubToken,
                  decoration: InputDecoration(
                    labelText: 'ghp_xxx...',
                    helperText: l10n.settingsGitHubTokenHelper,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureGitHubToken = !_obscureGitHubToken;
                        });
                      },
                      icon: Icon(
                        _obscureGitHubToken
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFFFB2AE)),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(l10n.commonSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
