import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _farmName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  String _language = 'en';
  String _currency = 'BDT';
  String _milkUnit = 'L';
  bool _lowStockAlerts = true;
  bool _backupReminder = true;
  bool _loaded = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _farmName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    await auth.loadProfile();
    if (!mounted) return;
    _applyProfile(auth.profile);
  }

  void _applyProfile(Map<String, dynamic> profile) {
    _farmName.text = '${profile['farm_name'] ?? ''}';
    _ownerName.text = '${profile['owner_name'] ?? ''}';
    _phone.text = '${profile['phone'] ?? ''}';
    _location.text = '${profile['farm_location'] ?? ''}';
    _language = '${profile['language_preference'] ?? 'en'}' == 'bn'
        ? 'bn'
        : 'en';
    _currency = '${profile['currency'] ?? 'BDT'}';
    _milkUnit = '${profile['milk_unit'] ?? 'L'}';
    _lowStockAlerts = profile['low_stock_alerts'] != false;
    _backupReminder = profile['backup_reminder'] != false;
    _loaded = true;
    context.read<LanguageProvider>().setBangla(_language == 'bn');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final farmName = _farmName.text.trim().isEmpty
        ? 'My Dairy Farm'
        : _farmName.text.trim();
    final ownerName = _ownerName.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.text('Profile & Settings', 'প্রোফাইল ও সেটিংস')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _ProfileHeader(
              farmName: farmName,
              ownerName: ownerName,
              offline: auth.isOfflineMode,
            ),
            const SizedBox(height: 14),
            _SettingsCard(
              title: lang.text('Farm profile', 'খামারের প্রোফাইল'),
              children: [
                TextField(
                  controller: _farmName,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Farm name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ownerName,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Owner name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _location,
                  decoration: const InputDecoration(labelText: 'Farm location'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsCard(
              title: lang.text('App preferences', 'অ্যাপ পছন্দ'),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _language,
                  decoration: const InputDecoration(labelText: 'App language'),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _language = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: const InputDecoration(labelText: 'Money unit'),
                  items: const [
                    DropdownMenuItem(value: 'BDT', child: Text('BDT / ৳')),
                    DropdownMenuItem(value: 'USD', child: Text('USD / \$')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _currency = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _milkUnit,
                  decoration: const InputDecoration(labelText: 'Milk unit'),
                  items: const [
                    DropdownMenuItem(value: 'L', child: Text('Liter (L)')),
                    DropdownMenuItem(value: 'kg', child: Text('Kilogram (kg)')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _milkUnit = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsCard(
              title: lang.text('Management settings', 'ম্যানেজমেন্ট সেটিংস'),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _lowStockAlerts,
                  onChanged: (value) => setState(() => _lowStockAlerts = value),
                  title: const Text('Show low stock warnings'),
                  subtitle: const Text('Warn when feed or stock goes low.'),
                ),
                const Divider(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _backupReminder,
                  onChanged: (value) => setState(() => _backupReminder = value),
                  title: const Text('Remind me to backup offline data'),
                  subtitle: const Text('Useful when using only this phone.'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: auth.isProfileLoading || !_loaded ? null : _save,
              icon: auth.isProfileLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save profile and settings'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _message!.startsWith('Saved')
                      ? const Color(0xFF147D64)
                      : Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              auth.isOfflineMode
                  ? 'Offline profile is saved on this phone.'
                  : 'Online profile is saved to your account. Extra app preferences are saved on this device.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF526166)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _message = null);
    try {
      await context.read<AuthProvider>().updateProfile(
        farmName: _farmName.text.trim().isEmpty
            ? 'My Dairy Farm'
            : _farmName.text.trim(),
        ownerName: _ownerName.text.trim(),
        phone: _phone.text.trim(),
        farmLocation: _location.text.trim(),
        languagePreference: _language,
        currency: _currency,
        milkUnit: _milkUnit,
        lowStockAlerts: _lowStockAlerts,
        backupReminder: _backupReminder,
      );
      if (!mounted) return;
      context.read<LanguageProvider>().setBangla(_language == 'bn');
      setState(() => _message = 'Saved profile and settings.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Could not save: $e');
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.farmName,
    required this.ownerName,
    required this.offline,
  });

  final String farmName;
  final String ownerName;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F4EF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFF147D64),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ownerName.isEmpty ? 'Owner name not added' : ownerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF526166)),
                  ),
                  const SizedBox(height: 6),
                  Chip(
                    label: Text(
                      offline ? 'Offline phone profile' : 'Online account',
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
