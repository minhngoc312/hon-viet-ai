import 'package:flutter/material.dart';

import '../models/explore_place.dart';
import 'destination_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final String languageCode;
  final String? initialCategory;

  const ExploreScreen({
    super.key,
    required this.languageCode,
    this.initialCategory,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? selectedCategory;
  String query = '';

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  String _t(String vi, String en) {
    return widget.languageCode == 'en' ? en : vi;
  }

  List<ExplorePlace> get filteredPlaces {
    final normalized = query.trim().toLowerCase();

    return explorePlaces.where((place) {
      final categoryMatch =
          selectedCategory == null || place.category == selectedCategory;

      final text =
          '${place.name(widget.languageCode)} '
                  '${place.location(widget.languageCode)}'
              .toLowerCase();

      final searchMatch = normalized.isEmpty || text.contains(normalized);

      return categoryMatch && searchMatch;
    }).toList();
  }

  void _openPlace(ExplorePlace place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(
          place: place,
          languageCode: widget.languageCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final categories = [
      (
        id: 'heritage',
        icon: Icons.account_balance,
        vi: 'Di sản',
        en: 'Heritage',
      ),
      (id: 'nature', icon: Icons.park, vi: 'Thiên nhiên', en: 'Nature'),
      (id: 'culture', icon: Icons.theater_comedy, vi: 'Văn hóa', en: 'Culture'),
      (id: 'art', icon: Icons.palette, vi: 'Nghệ thuật', en: 'Art'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_t('Khám phá', 'Explore'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              decoration: InputDecoration(
                hintText: _t('Tìm địa điểm...', 'Search places...'),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ChoiceChip(
                    label: Text(_t('Tất cả', 'All')),
                    selected: selectedCategory == null,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = null;
                      });
                    },
                  );
                }

                final category = categories[index - 1];

                return ChoiceChip(
                  avatar: Icon(category.icon, size: 18),
                  label: Text(_t(category.vi, category.en)),
                  selected: selectedCategory == category.id,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category.id;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredPlaces.isEmpty
                ? Center(
                    child: Text(
                      _t(
                        'Không tìm thấy địa điểm phù hợp.',
                        'No matching places found.',
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPlaces.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final place = filteredPlaces[index];

                      return Material(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _openPlace(place),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    place.emoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name(widget.languageCode),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        place.location(widget.languageCode),
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
