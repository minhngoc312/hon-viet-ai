import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/ai_service.dart';
import '../services/audio_guide_service.dart';
import '../widgets/save_place_button.dart';
import 'ai_guide_screen.dart';
import 'saved_places_screen.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final HeritageResult result;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  void _openAiGuide(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AiGuideScreen(result: result)));
  }

  Future<void> _openDirections(BuildContext context) async {
    final destination = result.location.trim().isNotEmpty
        ? '${result.name}, ${result.location}'
        : result.name;

    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': destination,
    });

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KhÃ´ng thá»ƒ má»Ÿ Google Maps.')),
      );
    }
  }

  void _openAudioGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio Guide',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  result.name,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.play_arrow_rounded),
                  ),
                  title: const Text('Nghe toÃ n bá»™ thuyáº¿t minh'),
                  subtitle: const Text(
                    'Giá»›i thiá»‡u, lá»‹ch sá»­, kiáº¿n trÃºc vÃ  lÆ°u Ã½ báº£o tá»“n',
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await AudioGuideService.speakFullGuide(result);
                  },
                ),
                if (result.history.trim().isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.history_edu_rounded),
                    ),
                    title: const Text('Chá»‰ nghe pháº§n lá»‹ch sá»­'),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await AudioGuideService.speakText(result.history);
                    },
                  ),
                if (result.architectureCulture.trim().isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.architecture_rounded),
                    ),
                    title: const Text('Kiáº¿n trÃºc & vÄƒn hÃ³a'),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await AudioGuideService.speakText(
                        result.architectureCulture,
                      );
                    },
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.stop_rounded)),
                  title: const Text('Dá»«ng phÃ¡t'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await AudioGuideService.stop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSavedPlaces(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SavedPlacesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 310,
            pinned: true,
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF9E1C16),
            actions: [
              SavePlaceButton(result: result, imagePath: imagePath),
              IconButton(
                tooltip: 'Saved Places',
                onPressed: () => _openSavedPlaces(context),
                icon: const Icon(Icons.bookmarks_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black87,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 70,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.20),
                          Colors.black.withValues(alpha: 0.80),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white70,
                              size: 17,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'AI IDENTIFIED',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(
                        icon: Icons.auto_awesome,
                        text: 'AI confidence ${result.confidence}%',
                      ),
                      if (result.category.isNotEmpty)
                        _buildBadge(
                          icon: Icons.account_balance_outlined,
                          text: result.category,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFFB3261E),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            result.location.isEmpty
                                ? 'ChÆ°a xÃ¡c Ä‘á»‹nh vá»‹ trÃ­'
                                : result.location,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildSection(
                    icon: Icons.info_outline_rounded,
                    title: 'Giá»›i thiá»‡u',
                    content: result.introduction,
                  ),
                  _buildSection(
                    icon: Icons.history_edu_rounded,
                    title: 'Lá»‹ch sá»­',
                    content: result.history,
                  ),
                  _buildSection(
                    icon: Icons.architecture_rounded,
                    title: 'Kiáº¿n trÃºc & vÄƒn hÃ³a',
                    content: result.architectureCulture,
                  ),
                  _buildConservationCard(),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openDirections(context),
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Directions'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB3261E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openAudioGuide(context),
                      icon: const Icon(Icons.headphones_rounded),
                      label: const Text('Audio Guide'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openAiGuide(context),
                      icon: const Icon(Icons.smart_toy_outlined),
                      label: const Text('Ask AI Guide'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB3261E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFB3261E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'Hồn Việt AI â€¢ Explore. Understand. Protect.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFB3261E)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFB3261E), size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConservationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB9E3C0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco_rounded, color: Color(0xFF2E7D32)),
              SizedBox(width: 9),
              Text(
                'Conservation Mode',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'ðŸŒ± HÃ£y cÃ¹ng báº£o vá»‡ di sáº£n',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          if (result.conservationTips.isEmpty)
            const Text('ChÆ°a cÃ³ hÆ°á»›ng dáº«n báº£o tá»“n.')
          else
            ...result.conservationTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF2E7D32),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
