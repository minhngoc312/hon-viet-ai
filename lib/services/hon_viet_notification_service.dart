import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HonVietNotification {
  final String id;
  final String titleVi;
  final String titleEn;
  final String bodyVi;
  final String bodyEn;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  const HonVietNotification({
    required this.id,
    required this.titleVi,
    required this.titleEn,
    required this.bodyVi,
    required this.bodyEn,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  String title(String languageCode) {
    return languageCode == 'en' ? titleEn : titleVi;
  }

  String body(String languageCode) {
    return languageCode == 'en' ? bodyEn : bodyVi;
  }

  HonVietNotification copyWith({bool? isRead}) {
    return HonVietNotification(
      id: id,
      titleVi: titleVi,
      titleEn: titleEn,
      bodyVi: bodyVi,
      bodyEn: bodyEn,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_vi': titleVi,
      'title_en': titleEn,
      'body_vi': bodyVi,
      'body_en': bodyEn,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  factory HonVietNotification.fromJson(Map<String, dynamic> json) {
    return HonVietNotification(
      id: (json['id'] ?? '').toString(),
      titleVi: (json['title_vi'] ?? '').toString(),
      titleEn: (json['title_en'] ?? '').toString(),
      bodyVi: (json['body_vi'] ?? '').toString(),
      bodyEn: (json['body_en'] ?? '').toString(),
      type: (json['type'] ?? 'info').toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      isRead: json['is_read'] == true,
    );
  }
}

class HonVietNotificationService {
  static const String _storageKey = 'hon_viet_notification_center_v2';

  static Future<List<HonVietNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_storageKey)) {
      await _write(_seedNotifications());
    }

    final raw = prefs.getStringList(_storageKey) ?? [];

    final items = <HonVietNotification>[];

    for (final item in raw) {
      try {
        items.add(
          HonVietNotification.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        // Bỏ qua item hỏng.
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items;
  }

  static Future<int> unreadCount() async {
    final items = await getNotifications();

    return items.where((item) => !item.isRead).length;
  }

  static Future<void> markRead(String id) async {
    final items = await getNotifications();

    final updated = items
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList();

    await _write(updated);
  }

  static Future<void> markAllRead() async {
    final items = await getNotifications();

    await _write(items.map((item) => item.copyWith(isRead: true)).toList());
  }

  static Future<void> delete(String id) async {
    final items = await getNotifications();

    items.removeWhere((item) => item.id == id);

    await _write(items);
  }

  static Future<void> restoreDefaults() async {
    await _write(_seedNotifications());
  }

  static Future<void> _write(List<HonVietNotification> items) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _storageKey,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  static List<HonVietNotification> _seedNotifications() {
    final now = DateTime.now();

    return [
      HonVietNotification(
        id: 'welcome',
        titleVi: 'Chào mừng đến Hồn Việt AI',
        titleEn: 'Welcome to Hồn Việt AI',
        bodyVi: 'Khám phá di sản Việt Nam bằng AI, bản đồ, Audio Guide và nhiều công cụ khác.',
        bodyEn: 'Explore Vietnamese heritage with AI recognition, maps, Audio Guide and more.',
        type: 'welcome',
        createdAt: now,
        isRead: false,
      ),
      HonVietNotification(
        id: 'scan_tip',
        titleVi: 'Mẹo nhận diện bằng AI',
        titleEn: 'AI scanning tip',
        bodyVi: 'Chụp toàn cảnh địa danh, đủ sáng và hạn chế vật cản để AI nhận diện chính xác hơn.',
        bodyEn: 'Capture a clear, well-lit view of the landmark with fewer obstructions for better AI recognition.',
        type: 'tip',
        createdAt: now.subtract(const Duration(minutes: 20)),
        isRead: false,
      ),
      HonVietNotification(
        id: 'explore_update',
        titleVi: 'Explore đã có nhiều địa điểm hơn',
        titleEn: 'Explore now has more places',
        bodyVi: 'Bạn có thể tìm kiếm và lọc nhiều địa danh theo Di sản, Thiên nhiên, Văn hóa và Nghệ thuật.',
        bodyEn: 'You can now search and filter more places by Heritage, Nature, Culture and Art.',
        type: 'update',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      HonVietNotification(
        id: 'conservation',
        titleVi: 'Cùng bảo vệ di sản',
        titleEn: 'Help protect heritage',
        bodyVi: 'Khi tham quan, hãy tôn trọng biển báo, không chạm hiện vật và giữ gìn vệ sinh khu di tích.',
        bodyEn: 'Please respect signs, avoid touching artifacts and keep heritage sites clean.',
        type: 'conservation',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      HonVietNotification(
        id: 'language',
        titleVi: 'Hồn Việt AI hỗ trợ Việt / English',
        titleEn: 'Hồn Việt AI supports Vietnamese / English',
        bodyVi: 'Bạn có thể đổi ngôn ngữ trong Cài đặt bất cứ lúc nào.',
        bodyEn: 'You can switch languages anytime from Settings.',
        type: 'language',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }
}
