import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../services/app_database.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.initialDefaultInstallDir});

  final String? initialDefaultInstallDir;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppDatabase _database = AppDatabase.instance;
  late final TextEditingController _defaultInstallDirController;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _defaultInstallDirController = TextEditingController(
      text: widget.initialDefaultInstallDir ?? '',
    );
  }

  @override
  void dispose() {
    _defaultInstallDirController.dispose();
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

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _database.setDefaultInstallBaseDir(
        _defaultInstallDirController.text,
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
        _error = '保存に失敗しました: $error';
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
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'デフォルトインストールディレクトリ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '新規登録時、空欄なら "デフォルトパス/アプリ名" を採用します。',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _defaultInstallDirController,
                        decoration: const InputDecoration(
                          labelText: '例: C:\\Tools または /opt/tools',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickDirectory,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Browse'),
                    ),
                  ],
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
                  label: const Text('保存'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
