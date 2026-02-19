import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/managed_app.dart';
import '../services/app_database.dart';
import '../widgets/app_editor_dialog.dart';
import '../widgets/atmosphere.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/simple_app_tile.dart';
import 'app_detail_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase _database = AppDatabase.instance;

  List<ManagedApp> _apps = const <ManagedApp>[];
  bool _loading = true;
  String? _loadError;
  String? _defaultInstallBaseDir;

  @override
  void initState() {
    super.initState();
    _refreshApps(withLoader: true);
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
      final defaultInstallDir = await _database.getDefaultInstallBaseDir();
      if (!mounted) {
        return;
      }
      setState(() {
        _apps = items;
        _defaultInstallBaseDir = defaultInstallDir;
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

  Future<void> _openAddDialog() async {
    final draft = await showDialog<ManagedAppDraft>(
      context: context,
      builder: (_) =>
          AppEditorDialog(defaultInstallBaseDir: _defaultInstallBaseDir),
    );

    if (!mounted || draft == null) {
      return;
    }

    try {
      await _database.addApp(draft);
      await _refreshApps();
      if (!mounted) {
        return;
      }
      _showSnackBar('ソースを追加しました。');
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

  Future<void> _openDetail(ManagedApp app) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AppDetailPage(
          app: app,
          defaultInstallBaseDir: _defaultInstallBaseDir,
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    await _refreshApps();
  }

  Future<void> _openSettings() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) =>
            SettingsPage(initialDefaultInstallDir: _defaultInstallBaseDir),
      ),
    );

    if (!mounted || changed != true) {
      return;
    }
    await _refreshApps();
    if (!mounted) {
      return;
    }
    _showSnackBar('設定を保存しました。');
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
            const Atmosphere(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    HomeTopBar(
                      onAdd: _openAddDialog,
                      onRefresh: () => _refreshApps(withLoader: true),
                      onSettings: _openSettings,
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
      return const Center(child: EmptyState());
    }

    return ListView.separated(
      itemCount: _apps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final app = _apps[index];
        return SimpleAppTile(
          app: app,
          busy: false,
          onTap: () => _openDetail(app),
        );
      },
    );
  }
}
