import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/wallhaven_api.dart';
import '../services/backup.dart';
import '../state/search_controller.dart';
import '../state/settings.dart';
import 'appearance_section.dart';
import 'layout_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _c;
  bool _hide = true;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: ref.read(apiKeyProvider));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toast(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m)));

  Future<void> _save() async {
    await ref.read(apiKeyProvider.notifier).set(_c.text);
    await ref.read(searchProvider.notifier).applyParams(const SearchParams());
    if (mounted) _toast('API key saved');
  }

  Future<void> _export() async {
    var include = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Export backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saves your favorites and layout settings to a file.'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Include API key'),
                subtitle: const Text(
                    'Anyone with the file can use your key. Keep it private.'),
                value: include,
                onChanged: (v) => setS(() => include = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Export')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      final path =
          await ref.read(backupProvider).export(includeKey: include);
      if (mounted) _toast(path == null ? 'Export cancelled' : 'Backup saved');
    } catch (_) {
      if (mounted) _toast('Export failed');
    }
  }

  Future<void> _import() async {
    try {
      final r = await ref.read(backupProvider).import();
      if (!mounted || r == null) return;
      _c.text = ref.read(apiKeyProvider); // show the imported key
      _toast(r.summary);
    } on FormatException catch (e) {
      if (mounted) _toast(e.message);
    } catch (_) {
      if (mounted) _toast('Import failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Layout'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LayoutSettingsScreen()),
            ),
          ),
          const Divider(),
          const AppearanceSection(),
          const Divider(),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            obscureText: _hide,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Wallhaven API key',
              helperText: 'Get it at wallhaven.cc/settings/account',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _hide = !_hide),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _save, child: const Text('Save')),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Export backup'),
            subtitle: const Text('Favorites, layout and API key'),
            onTap: _export,
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Import backup'),
            subtitle: const Text('Favorites are merged with the ones you have'),
            onTap: _import,
          ),
        ],
      ),
    );
  }
}
