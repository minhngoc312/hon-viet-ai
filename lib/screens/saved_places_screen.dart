import 'dart:io';

import 'package:flutter/material.dart';

import '../models/saved_place.dart';
import '../services/saved_places_service.dart';
import 'result_screen.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  List<SavedPlace> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final places = await SavedPlacesService.getSavedPlaces();

    if (!mounted) return;

    setState(() {
      _places = places;
      _isLoading = false;
    });
  }

  Future<void> _remove(SavedPlace place) async {
    await SavedPlacesService.removeById(place.id);

    await _load();
  }

  Future<void> _openPlace(SavedPlace place) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ResultScreen(imagePath: place.imagePath, result: place.result),
      ),
    );

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Saved Places'),
        backgroundColor: const Color(0xFFB3261E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _places.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _places.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final place = _places[index];

                  return _buildCard(place);
                },
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 76,
              color: Colors.black26,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có địa danh đã lưu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sau khi AI nhận diện một địa danh, '
              'nhấn biểu tượng trái tim để lưu lại.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(SavedPlace place) {
    final image = File(place.imagePath);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openPlace(place),
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 120,
              child: FutureBuilder<bool>(
                future: image.exists(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Image.file(image, fit: BoxFit.cover);
                  }

                  return Container(
                    color: const Color(0xFFFFECE9),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFFB3261E),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.result.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      place.result.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (place.result.category.trim().isNotEmpty)
                      Text(
                        place.result.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB3261E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Xóa',
              onPressed: () => _remove(place),
              icon: const Icon(Icons.delete_outline),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
