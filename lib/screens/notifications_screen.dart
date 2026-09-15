import 'package:flutter/material.dart';

import '../services/hon_viet_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String languageCode;

  const NotificationsScreen({super.key, required this.languageCode});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<HonVietNotification> _items = [];
  bool _isLoading = true;

  bool get _isEnglish => widget.languageCode == 'en';

  String _l(String vi, String en) {
    return _isEnglish ? en : vi;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await HonVietNotificationService.getNotifications();

    if (!mounted) return;

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _markRead(HonVietNotification item) async {
    if (item.isRead) return;

    await HonVietNotificationService.markRead(item.id);

    await _load();
  }

  Future<void> _markAllRead() async {
    await HonVietNotificationService.markAllRead();
    await _load();
  }

  Future<void> _delete(HonVietNotification item) async {
    await HonVietNotificationService.delete(item.id);

    await _load();
  }

  Future<void> _restoreDefaults() async {
    await HonVietNotificationService.restoreDefaults();
    await _load();
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'tip':
        return Icons.lightbulb_outline_rounded;
      case 'update':
        return Icons.new_releases_outlined;
      case 'conservation':
        return Icons.eco_outlined;
      case 'language':
        return Icons.language_rounded;
      case 'welcome':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return _l('Vừa xong', 'Just now');
    }

    if (difference.inHours < 1) {
      return _l(
        '${difference.inMinutes} phút trước',
        '${difference.inMinutes} min ago',
      );
    }

    if (difference.inDays < 1) {
      return _l(
        '${difference.inHours} giờ trước',
        '${difference.inHours} hr ago',
      );
    }

    return _l(
      '${difference.inDays} ngày trước',
      '${difference.inDays} days ago',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_l('Thông báo', 'Notifications')),
        actions: [
          if (_items.any((item) => !item.isRead))
            TextButton(
              onPressed: _markAllRead,
              child: Text(_l('Đọc tất cả', 'Mark all read')),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? _emptyState(context)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _items[index];

                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.onErrorContainer,
                      ),
                    ),
                    onDismissed: (_) => _delete(item),
                    child: Material(
                      color: item.isRead
                          ? colors.surface
                          : colors.primaryContainer.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _markRead(item),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: colors.primaryContainer,
                                foregroundColor: colors.onPrimaryContainer,
                                child: Icon(_iconFor(item.type)),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title(widget.languageCode),
                                            style: TextStyle(
                                              fontWeight: item.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead)
                                          Container(
                                            width: 9,
                                            height: 9,
                                            decoration: BoxDecoration(
                                              color: colors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.body(widget.languageCode),
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _relativeTime(item.createdAt),
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 72,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              _l('Chưa có thông báo', 'No notifications yet'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _l(
                'Thông báo về tính năng, mẹo sử dụng và gợi ý khám phá sẽ xuất hiện ở đây.',
                'Feature updates, tips and discovery suggestions will appear here.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _restoreDefaults,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                _l('Khôi phục thông báo mẫu', 'Restore sample notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
