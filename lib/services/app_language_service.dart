import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageService {
  static const String _languageKey = 'hon_viet_language';

  static Future<String> loadLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languageKey);

    if (saved == 'en') {
      return 'en';
    }

    return 'vi';
  }

  static Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_languageKey, languageCode == 'en' ? 'en' : 'vi');
  }
}

class AppText {
  static const Map<String, Map<String, String>> _values = {
    'vi': {
      'home': 'Trang chủ',
      'explore': 'Khám phá',
      'saved': 'Đã lưu',
      'profile': 'Hồ sơ',
      'settings': 'Cài đặt',
      'discover_vietnam': 'Khám phá Việt Nam',
      'new_perspective': 'qua một góc nhìn mới.',
      'hero_subtitle': 'Khám phá văn hóa, lịch sử và di sản Việt Nam cùng AI.',
      'scan_place': 'Quét địa điểm di sản',
      'scan_subtitle': 'Chụp ảnh và để AI nhận diện địa danh.',
      'start_scanning': 'Bắt đầu quét',
      'explore_nearby': 'Khám phá theo chủ đề',
      'heritage': 'Di sản',
      'nature': 'Thiên nhiên',
      'culture': 'Văn hóa',
      'art': 'Nghệ thuật',
      'popular_destinations': 'Địa điểm nổi bật',
      'see_all': 'Xem tất cả',
      'hoi_an': 'Phố cổ Hội An',
      'hue': 'Đại Nội Huế',
      'trang_an': 'Tràng An',
      'cultural_heritage': 'Di sản văn hóa',
      'historical_heritage': 'Di sản lịch sử',
      'natural_heritage': 'Di sản thiên nhiên',
      'explore_placeholder': 'Khám phá các địa điểm di sản và văn hóa nổi bật.',
      'saved_placeholder': 'Các địa điểm bạn đã lưu sẽ xuất hiện ở đây.',
      'account': 'Tài khoản',
      'appearance': 'Giao diện',
      'app': 'Ứng dụng',
      'not_logged_in': 'Bạn chưa đăng nhập',
      'login_hint': 'Đăng nhập để quản lý hồ sơ và đồng bộ hành trình sau này.',
      'login': 'Đăng nhập',
      'display_mode': 'Chế độ hiển thị',
      'display_mode_hint': 'Chọn sáng, tối hoặc theo cài đặt của thiết bị.',
      'system': 'Hệ thống',
      'light': 'Sáng',
      'dark': 'Tối',
      'language': 'Ngôn ngữ',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'cancel': 'Hủy',
      'display_name': 'Tên hiển thị',
      'email': 'Email',
      'invalid_login': 'Vui lòng nhập tên và email hợp lệ.',
      'edit_info': 'Sửa thông tin',
      'logout': 'Đăng xuất',
      'logged_out': 'Đã đăng xuất.',
      'profile_title': 'Hồ sơ',
      'guest': 'Khách',
      'guest_subtitle': 'Đăng nhập để cá nhân hóa hành trình khám phá.',
      'your_journey': 'Hành trình của bạn',
      'saved_places': 'Địa điểm đã lưu',
      'discover_more': 'Khám phá thêm',
      'manage_account': 'Quản lý tài khoản',
      'preferences': 'Tùy chọn',
      'current_language': 'Ngôn ngữ hiện tại',
      'current_theme': 'Giao diện hiện tại',
      'theme_system': 'Theo hệ thống',
      'theme_light': 'Chế độ sáng',
      'theme_dark': 'Chế độ tối',
      'hon_viet_member': 'Thành viên Hồn Việt AI',
      'local_account_notice': 'Tài khoản hiện được lưu cục bộ trên thiết bị.',
    },
    'en': {
      'home': 'Home',
      'explore': 'Explore',
      'saved': 'Saved',
      'profile': 'Profile',
      'settings': 'Settings',
      'discover_vietnam': 'Discover Vietnam',
      'new_perspective': 'through a new perspective.',
      'hero_subtitle':
          'Explore Vietnamese culture, history and heritage with AI.',
      'scan_place': 'Scan a Heritage Place',
      'scan_subtitle': 'Take a photo and let AI identify the landmark.',
      'start_scanning': 'Start scanning',
      'explore_nearby': 'Explore by category',
      'heritage': 'Heritage',
      'nature': 'Nature',
      'culture': 'Culture',
      'art': 'Art',
      'popular_destinations': 'Popular destinations',
      'see_all': 'See all',
      'hoi_an': 'Hội An Ancient Town',
      'hue': 'Imperial City of Huế',
      'trang_an': 'Tràng An',
      'cultural_heritage': 'Cultural Heritage',
      'historical_heritage': 'Historical Heritage',
      'natural_heritage': 'Natural Heritage',
      'explore_placeholder':
          'Discover remarkable heritage and cultural destinations.',
      'saved_placeholder': 'Places you save will appear here.',
      'account': 'Account',
      'appearance': 'Appearance',
      'app': 'App',
      'not_logged_in': 'You are not signed in',
      'login_hint':
          'Sign in to manage your profile and sync your journey later.',
      'login': 'Sign in',
      'display_mode': 'Display mode',
      'display_mode_hint':
          'Choose light, dark, or follow your device settings.',
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',
      'language': 'Language',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'cancel': 'Cancel',
      'display_name': 'Display name',
      'email': 'Email',
      'invalid_login': 'Please enter a valid name and email.',
      'edit_info': 'Edit information',
      'logout': 'Sign out',
      'logged_out': 'Signed out.',
      'profile_title': 'Profile',
      'guest': 'Guest',
      'guest_subtitle': 'Sign in to personalize your heritage journey.',
      'your_journey': 'Your journey',
      'saved_places': 'Saved places',
      'discover_more': 'Discover more',
      'manage_account': 'Manage account',
      'preferences': 'Preferences',
      'current_language': 'Current language',
      'current_theme': 'Current theme',
      'theme_system': 'System default',
      'theme_light': 'Light mode',
      'theme_dark': 'Dark mode',
      'hon_viet_member': 'Hồn Việt AI member',
      'local_account_notice':
          'Your account is currently stored locally on this device.',
    },
  };

  static String t(String languageCode, String key) {
    final language = languageCode == 'en' ? 'en' : 'vi';

    return _values[language]?[key] ?? _values['en']?[key] ?? key;
  }
}
