import 'package:flutter/material.dart';

import '../services/app_language_service.dart';
import '../services/app_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.languageCode,
    required this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LocalAccount? _account;
  bool _isLoadingAccount = true;
  bool _notificationsEnabled = true;

  bool get _isEnglish => widget.languageCode == 'en';

  String _t(String key) {
    return AppText.t(widget.languageCode, key);
  }

  String _l(String vi, String en) {
    return _isEnglish ? en : vi;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final account = await AppSettingsService.loadAccount();
    final notificationsEnabled =
        await AppSettingsService.loadNotificationsEnabled();

    if (!mounted) return;

    setState(() {
      _account = account;
      _notificationsEnabled = notificationsEnabled;
      _isLoadingAccount = false;
    });
  }

  Future<void> _openAccountEditor() async {
    final nameController = TextEditingController(text: _account?.name ?? '');
    final emailController = TextEditingController(text: _account?.email ?? '');
    final phoneController = TextEditingController(text: _account?.phone ?? '');
    final countryController = TextEditingController(
      text: _account?.country ?? '',
    );
    final bioController = TextEditingController(text: _account?.bio ?? '');

    final result = await showModalBottomSheet<LocalAccount>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _account == null
                      ? _l('Thiết lập tài khoản', 'Set up account')
                      : _l('Chỉnh sửa hồ sơ', 'Edit profile'),
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _l(
                    'Thông tin này hiện được lưu trên thiết bị của bạn.',
                    'This information is currently stored on your device.',
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: _t('display_name'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: _t('email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _l('Số điện thoại', 'Phone number'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: countryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: _l('Quốc gia / Khu vực', 'Country / Region'),
                    prefixIcon: const Icon(Icons.public_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  maxLength: 120,
                  decoration: InputDecoration(
                    labelText: _l('Giới thiệu ngắn', 'Short bio'),
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final email = emailController.text.trim();

                      if (name.isEmpty ||
                          email.isEmpty ||
                          !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_t('invalid_login'))),
                        );
                        return;
                      }

                      Navigator.of(sheetContext).pop(
                        LocalAccount(
                          name: name,
                          email: email,
                          phone: phoneController.text.trim(),
                          country: countryController.text.trim(),
                          bio: bioController.text.trim(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      _account == null
                          ? _t('login')
                          : _l('Lưu thay đổi', 'Save changes'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    bioController.dispose();

    if (result == null) return;

    await AppSettingsService.saveAccount(
      name: result.name,
      email: result.email,
      phone: result.phone,
      country: result.country,
      bio: result.bio,
    );

    if (!mounted) return;

    setState(() {
      _account = result;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_l('Đã lưu hồ sơ.', 'Profile saved.'))),
    );
  }

  Future<void> _logout() async {
    await AppSettingsService.clearAccount();

    if (!mounted) return;

    setState(() {
      _account = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_t('logged_out'))));
  }

  Future<void> _setNotificationsEnabled(bool enabled) async {
    setState(() {
      _notificationsEnabled = enabled;
    });

    await AppSettingsService.saveNotificationsEnabled(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_t('settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _sectionTitle(context, _t('account')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoadingAccount
                  ? const Center(child: CircularProgressIndicator())
                  : _account == null
                  ? _loggedOutCard(context)
                  : _loggedInCard(context, _account!),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, _t('appearance')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.brightness_6_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _t('display_mode'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t('display_mode_hint'),
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.settings_suggest_outlined),
                          label: Text(_t('system')),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_outlined),
                          label: Text(_t('light')),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_outlined),
                          label: Text(_t('dark')),
                        ),
                      ],
                      selected: {widget.themeMode},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) {
                        if (selection.isEmpty) {
                          return;
                        }

                        widget.onThemeModeChanged(selection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, _l('Thông báo', 'Notifications')),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: Text(
                _l(
                  'Bật thông báo trong ứng dụng',
                  'Enable in-app notifications',
                ),
              ),
              subtitle: Text(
                _l(
                  'Nhận mẹo sử dụng, cập nhật tính năng và gợi ý khám phá.',
                  'Get tips, feature updates and discovery suggestions.',
                ),
              ),
              value: _notificationsEnabled,
              onChanged: _setNotificationsEnabled,
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, _t('app')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded),
                      const SizedBox(width: 12),
                      Text(
                        _t('language'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'vi',
                          label: Text(_t('vietnamese')),
                        ),
                        ButtonSegment(value: 'en', label: Text(_t('english'))),
                      ],
                      selected: {widget.languageCode},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) {
                        if (selection.isEmpty) {
                          return;
                        }

                        widget.onLanguageChanged(selection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('Hồn Việt AI'),
                    subtitle: Text('Explore. Understand. Protect.'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loggedOutCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: const Icon(Icons.person_outline_rounded, size: 34),
        ),
        const SizedBox(height: 12),
        Text(
          _t('not_logged_in'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          _t('login_hint'),
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openAccountEditor,
            icon: const Icon(Icons.login_rounded),
            label: Text(_t('login')),
          ),
        ),
      ],
    );
  }

  Widget _loggedInCard(BuildContext context, LocalAccount account) {
    final colors = Theme.of(context).colorScheme;

    final cleanName = account.name.trim();
    final initial = cleanName.isEmpty
        ? '?'
        : cleanName.substring(0, 1).toUpperCase();

    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    account.email,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _openAccountEditor();
                } else if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(_t('edit_info'))),
                PopupMenuItem(value: 'logout', child: Text(_t('logout'))),
              ],
            ),
          ],
        ),
        if (account.phone.isNotEmpty ||
            account.country.isNotEmpty ||
            account.bio.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (account.phone.isNotEmpty)
            _infoRow(context, Icons.phone_outlined, account.phone),
          if (account.country.isNotEmpty)
            _infoRow(context, Icons.public_rounded, account.country),
          if (account.bio.isNotEmpty)
            _infoRow(context, Icons.format_quote_rounded, account.bio),
        ],
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 9),
          Expanded(
            child: Text(text, style: TextStyle(color: colors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
