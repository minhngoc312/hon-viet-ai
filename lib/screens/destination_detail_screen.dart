import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/explore_place.dart';

class DestinationDetailScreen extends StatelessWidget {
  final ExplorePlace place;
  final String languageCode;

  const DestinationDetailScreen({
    super.key,
    required this.place,
    required this.languageCode,
  });

  String _t(String vi, String en) {
    return languageCode == 'en' ? en : vi;
  }

  Future<void> _openDirections(BuildContext context) async {
    final destination =
        '${place.name(languageCode)}, '
        '${place.location(languageCode)}';

    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': destination,
    });

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('Không thể mở Google Maps.', 'Could not open Google Maps.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(place.name(languageCode))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            height: 190,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer,
                  colors.surfaceContainerHighest,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(place.emoji, style: const TextStyle(fontSize: 82)),
          ),
          const SizedBox(height: 22),
          Text(
            place.name(languageCode),
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: colors.primary, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  place.location(languageCode),
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _t('Giới thiệu', 'About'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            place.description(languageCode),
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => _openDirections(context),
            icon: const Icon(Icons.directions_rounded),
            label: Text(_t('Chỉ đường', 'Directions')),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              _t('Quay lại để quét bằng AI', 'Go back to scan with AI'),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
