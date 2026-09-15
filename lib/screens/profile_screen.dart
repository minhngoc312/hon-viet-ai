import 'package:flutter/material.dart';

import '../services/app_language_service.dart';
import '../services/app_settings_service.dart';

class ProfileScreen extends StatelessWidget {
  final String languageCode;
  final ThemeMode themeMode;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenExplore;
  final VoidCallback onOpenSettings;

  const ProfileScreen({
    super.key,
    required this.languageCode,
    required this.themeMode,
    required this.onOpenSaved,
    required this.onOpenExplore,
    required this.onOpenSettings,
  });

  bool get _isEnglish => languageCode == 'en';

  String _t(String key) {
    return AppText.t(languageCode, key);
  }

  String _l(String vi, String en) {
    return _isEnglish ? en : vi;
  }

  String _themeLabel() {
    switch (themeMode) {
      case ThemeMode.light:
        return _t('theme_light');
      case ThemeMode.dark:
        return _t('theme_dark');
      case ThemeMode.system:
        return _t('theme_system');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_t('profile_title'))),
      body: FutureBuilder<LocalAccount?>(
        future: AppSettingsService.loadAccount(),
        builder: (context, snapshot) {
          final account = snapshot.data;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _profileHeader(context, account),
              if (account != null) ...[
                const SizedBox(height: 14),
                _accountDetails(context, account),
              ],
              const SizedBox(height: 22),
              Text(
                _t('your_journey'),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      context,
                      icon: Icons.favorite_rounded,
                      title: _t('saved_places'),
                      onTap: onOpenSaved,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickAction(
                      context,
                      icon: Icons.explore_rounded,
                      title: _t('discover_more'),
                      onTap: onOpenExplore,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                _t('preferences'),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: Text(_t('current_language')),
                      subtitle: Text(
                        languageCode == 'en' ? _t('english') : _t('vietnamese'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                      ),
                      title: Text(_t('current_theme')),
                      subtitle: Text(_themeLabel()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(_t('manage_account')),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _t('local_account_notice'),
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileHeader(BuildContext context, LocalAccount? account) {
    final colors = Theme.of(context).colorScheme;

    final isLoggedIn = account != null;
    final name = account?.name ?? _t('guest');
    final subtitle = account?.email ?? _t('guest_subtitle');

    final cleanName = name.trim();
    final initial = cleanName.isEmpty
        ? '?'
        : cleanName.substring(0, 1).toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  if (isLoggedIn) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _t('hon_viet_member'),
                        style: TextStyle(
                          color: colors.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountDetails(BuildContext context, LocalAccount account) {
    final rows = <Widget>[];

    if (account.phone.isNotEmpty) {
      rows.add(
        _detailRow(
          context,
          Icons.phone_outlined,
          _l('Điện thoại', 'Phone'),
          account.phone,
        ),
      );
    }

    if (account.country.isNotEmpty) {
      rows.add(
        _detailRow(
          context,
          Icons.public_rounded,
          _l('Quốc gia / Khu vực', 'Country / Region'),
          account.country,
        ),
      );
    }

    if (account.bio.isNotEmpty) {
      rows.add(
        _detailRow(
          context,
          Icons.format_quote_rounded,
          _l('Giới thiệu', 'About'),
          account.bio,
        ),
      );
    }

    if (rows.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.person_add_alt_rounded),
          title: Text(_l('Hoàn thiện hồ sơ', 'Complete your profile')),
          subtitle: Text(
            _l(
              'Thêm số điện thoại, quốc gia và giới thiệu ngắn trong Cài đặt.',
              'Add your phone, country and short bio in Settings.',
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onOpenSettings,
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: rows),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 30, color: colors.primary),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
