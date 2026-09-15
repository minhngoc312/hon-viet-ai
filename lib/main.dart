import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/explore_place.dart';
import 'screens/destination_detail_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'services/app_language_service.dart';
import 'services/app_settings_service.dart';
import 'services/hon_viet_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeMode = await AppSettingsService.loadThemeMode();
  final languageCode = await AppLanguageService.loadLanguageCode();

  runApp(
    HonVietAIApp(
      initialThemeMode: themeMode,
      initialLanguageCode: languageCode,
    ),
  );
}

class HonVietAIApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final String initialLanguageCode;

  const HonVietAIApp({
    super.key,
    required this.initialThemeMode,
    this.initialLanguageCode = 'vi',
  });

  @override
  State<HonVietAIApp> createState() => _HonVietAIAppState();
}

class _HonVietAIAppState extends State<HonVietAIApp> {
  late ThemeMode _themeMode;
  late String _languageCode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _languageCode = widget.initialLanguageCode == 'en' ? 'en' : 'vi';
  }

  Future<void> _changeThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });

    await AppSettingsService.saveThemeMode(mode);
  }

  Future<void> _changeLanguage(String languageCode) async {
    final normalized = languageCode == 'en' ? 'en' : 'vi';

    setState(() {
      _languageCode = normalized;
    });

    await AppLanguageService.saveLanguageCode(normalized);
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB3261E),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF7F7F7)
          : const Color(0xFF121212),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFFFFECE9)
            : colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hồn Việt AI',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      locale: Locale(_languageCode),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomeScreen(
        themeMode: _themeMode,
        languageCode: _languageCode,
        onThemeModeChanged: _changeThemeMode,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final String languageCode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<String> onLanguageChanged;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.languageCode,
    required this.onThemeModeChanged,
    required this.onLanguageChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotifications();
  }

  Future<void> _loadUnreadNotifications() async {
    final enabled = await AppSettingsService.loadNotificationsEnabled();

    if (!enabled) {
      if (!mounted) return;

      setState(() {
        _unreadNotifications = 0;
      });

      return;
    }

    final count = await HonVietNotificationService.unreadCount();

    if (!mounted) return;

    setState(() {
      _unreadNotifications = count;
    });
  }

  String _t(String key) {
    return AppText.t(widget.languageCode, key);
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'heritage':
        return _t('cultural_heritage');
      case 'nature':
        return _t('natural_heritage');
      case 'culture':
        return _t('cultural_heritage');
      case 'art':
        return _t('art');
      default:
        return category;
    }
  }

  void openScanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );
  }

  void _goToTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _openExplore({String? category}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExploreScreen(
          languageCode: widget.languageCode,
          initialCategory: category,
        ),
      ),
    );
  }

  void _openDestination(ExplorePlace place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(
          place: place,
          languageCode: widget.languageCode,
        ),
      ),
    );
  }

  Future<void> _openNotifications() async {
    final enabled = await AppSettingsService.loadNotificationsEnabled();

    if (!enabled) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.languageCode == 'en'
                ? 'Notifications are disabled in Settings.'
                : 'Thông báo đang tắt trong Cài đặt.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(languageCode: widget.languageCode),
      ),
    );

    await _loadUnreadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: [
            buildHomePage(),
            ExploreScreen(languageCode: widget.languageCode),
            buildPlaceholderPage(
              icon: Icons.favorite,
              title: _t('saved'),
              subtitle: _t('saved_placeholder'),
            ),
            ProfileScreen(
              languageCode: widget.languageCode,
              themeMode: widget.themeMode,
              onOpenSaved: () => _goToTab(2),
              onOpenExplore: () => _goToTab(1),
              onOpenSettings: () => _goToTab(4),
            ),
            SettingsScreen(
              themeMode: widget.themeMode,
              onThemeModeChanged: widget.onThemeModeChanged,
              languageCode: widget.languageCode,
              onLanguageChanged: widget.onLanguageChanged,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _goToTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: _t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: _t('explore'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: _t('saved'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: _t('profile'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: _t('settings'),
          ),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\u{1F1FB}\u{1F1F3}', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Hồn Việt AI',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Material(
                color: colors.surfaceContainerHighest,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _openNotifications,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: colors.onSurface,
                          ),
                        ),
                        if (_unreadNotifications > 0)
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 17,
                                minHeight: 17,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _unreadNotifications > 9
                                    ? '9+'
                                    : '$_unreadNotifications',
                                style: TextStyle(
                                  color: colors.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            _t('discover_vietnam'),
            style: const TextStyle(fontSize: 31, fontWeight: FontWeight.bold),
          ),
          Text(
            _t('new_perspective'),
            style: TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _t('hero_subtitle'),
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9E1C16), Color(0xFFE35646)],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 15,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _t('scan_place'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _t('scan_subtitle'),
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: openScanScreen,
                    icon: const Icon(Icons.center_focus_strong),
                    label: Text(_t('start_scanning')),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB3261E),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _t('explore_nearby'),
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryItem(
                icon: Icons.account_balance,
                title: _t('heritage'),
                onTap: () => _openExplore(category: 'heritage'),
              ),
              CategoryItem(
                icon: Icons.park,
                title: _t('nature'),
                onTap: () => _openExplore(category: 'nature'),
              ),
              CategoryItem(
                icon: Icons.theater_comedy,
                title: _t('culture'),
                onTap: () => _openExplore(category: 'culture'),
              ),
              CategoryItem(
                icon: Icons.palette,
                title: _t('art'),
                onTap: () => _openExplore(category: 'art'),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _t('popular_destinations'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _openExplore(),
                child: Text(_t('see_all')),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            explorePlaces[0],
            explorePlaces[1],
            explorePlaces[2],
            explorePlaces[3],
            explorePlaces[4],
            explorePlaces[6],
          ].map(
            (place) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DestinationCard(
                emoji: place.emoji,
                name: place.name(widget.languageCode),
                location: place.location(widget.languageCode),
                category: _categoryLabel(place.category),
                onTap: () => _openDestination(place),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlaceholderPage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: colors.primary),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 62,
                height: 62,
                child: Icon(icon, color: colors.primary, size: 29),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String location;
  final String category;
  final VoidCallback? onTap;

  const DestinationCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.location,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      location,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
