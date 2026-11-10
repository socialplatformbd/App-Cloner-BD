import 'package:flutter/material.dart';
import '../models/installed_app.dart';
import '../services/native_app_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.onThemeChanged,
    required this.themeMode,
    super.key,
  });

  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode themeMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NativeAppService _service = NativeAppService();
  final TextEditingController _searchController = TextEditingController();
  List<InstalledApp> _apps = const [];
  bool _loading = true;
  String? _error;
  String _query = '';
  String _capabilityMessage =
      'App cloning is not enabled in this foundation build.';

  List<InstalledApp> get _filteredApps {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _apps;
    return _apps.where((app) {
      return app.label.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _service.getLaunchableApps();
      final capability = await _service.getCloneCapabilityMessage();
      if (!mounted) return;
      setState(() {
        _apps = results;
        _capabilityMessage = capability;
        _loading = false;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'Android could not read the app list.';
        _loading = false;
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unexpected error while loading installed apps.';
        _loading = false;
      });
    }
  }

  void _showCloneInfo(InstalledApp app) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(app.label),
        content: Text(
          'Clone Engine এখনো যুক্ত করা হয়নি। Android-এর অনুমোদিত '
          'Managed Profile / profile-owner ব্যবস্থা ও ডিভাইস compatibility '
          'যাচাইয়ের পর এই অ্যাপের জন্য cloning চালু করা যাবে।\n\n'
          'Package: ${app.packageName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  void _showThemeMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Appearance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _themeOption('System default', ThemeMode.system),
              _themeOption('Light mode', ThemeMode.light),
              _themeOption('Dark mode', ThemeMode.dark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOption(String label, ThemeMode mode) {
    return ListTile(
      title: Text(label),
      trailing: widget.themeMode == mode
          ? const Icon(Icons.check_circle, color: Color(0xFF7657E8))
          : null,
      onTap: () {
        widget.onThemeChanged(mode);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apps = _filteredApps;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.layers_rounded, color: Color(0xFF9278FF)),
            SizedBox(width: 10),
            Text(
              'App Cloner BD',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Change theme',
            onPressed: _showThemeMenu,
            icon: const Icon(Icons.contrast_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadApps,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _buildHero(theme),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _statCard('Detected apps', '${_apps.length}', Icons.apps_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Active clones', '0', Icons.copy_all_rounded)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Installed applications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: _loadApps,
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search apps or package name',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _messageCard(_error!, onRetry: _loadApps)
            else if (apps.isEmpty)
              _messageCard(
                _apps.isEmpty
                    ? 'কোনো launchable app পাওয়া যায়নি। নিচে টেনে refresh করুন।'
                    : 'আপনার search-এর সঙ্গে কোনো app মেলেনি।',
                onRetry: _loadApps,
              )
            else
              ...apps.map(_appTile),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFF9278FF)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _capabilityMessage,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6546D8), Color(0xFF30266F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'One phone. More possibilities.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Discover apps and manage your cloning workspace.',
            style: TextStyle(color: Color(0xFFE2DCFF), height: 1.4),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: Colors.white70, size: 17),
              SizedBox(width: 7),
              Text(
                'Privacy-first Android foundation',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF9278FF)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _appTile(InstalledApp app) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7657E8).withValues(alpha: 0.13),
          child: const Icon(Icons.android_rounded, color: Color(0xFF9278FF)),
        ),
        title: Text(app.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          app.packageName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Clone information',
          onPressed: () => _showCloneInfo(app),
          icon: const Icon(Icons.copy_rounded),
        ),
      ),
    );
  }

  Widget _messageCard(String message, {required VoidCallback onRetry}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
