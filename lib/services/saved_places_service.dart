import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_place.dart';
import 'ai_service.dart';

class SavedPlacesService {
  static const String _storageKey = 'viet_heritage_saved_places_v1';

  static String placeId(HeritageResult result) {
    return '${result.name.trim().toLowerCase()}|'
        '${result.location.trim().toLowerCase()}';
  }

  static Future<List<SavedPlace>> getSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();

    final rawItems = prefs.getStringList(_storageKey) ?? [];

    final items = <SavedPlace>[];

    for (final raw in rawItems) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;

        items.add(SavedPlace.fromJson(data));
      } catch (_) {
        // Bỏ qua entry hỏng thay vì làm crash app.
      }
    }

    items.sort((a, b) => b.savedAt.compareTo(a.savedAt));

    return items;
  }

  static Future<bool> isSaved(HeritageResult result) async {
    final id = placeId(result);
    final items = await getSavedPlaces();

    return items.any((item) => item.id == id);
  }

  static Future<bool> toggleSave({
    required HeritageResult result,
    required String imagePath,
  }) async {
    final id = placeId(result);
    final items = await getSavedPlaces();

    final existingIndex = items.indexWhere((item) => item.id == id);

    if (existingIndex >= 0) {
      final existing = items.removeAt(existingIndex);

      await _deleteStoredImage(existing.imagePath);

      await _write(items);
      return false;
    }

    final storedImagePath = await _persistImage(imagePath);

    items.add(
      SavedPlace(
        id: id,
        imagePath: storedImagePath,
        result: result,
        savedAt: DateTime.now(),
      ),
    );

    await _write(items);
    return true;
  }

  static Future<void> removeById(String id) async {
    final items = await getSavedPlaces();

    final index = items.indexWhere((item) => item.id == id);

    if (index < 0) return;

    final removed = items.removeAt(index);

    await _deleteStoredImage(removed.imagePath);

    await _write(items);
  }

  static Future<void> _write(List<SavedPlace> items) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _storageKey,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  static Future<String> _persistImage(String sourcePath) async {
    try {
      final source = File(sourcePath);

      if (!await source.exists()) {
        return sourcePath;
      }

      final docs = await getApplicationDocumentsDirectory();

      final directory = Directory(
        '${docs.path}${Platform.pathSeparator}'
        'saved_places',
      );

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final extension = _fileExtension(sourcePath);

      final destination =
          '${directory.path}'
          '${Platform.pathSeparator}'
          '${DateTime.now().microsecondsSinceEpoch}'
          '$extension';

      final copied = await source.copy(destination);

      return copied.path;
    } catch (_) {
      // Nếu copy ảnh thất bại vẫn lưu dữ liệu địa danh.
      return sourcePath;
    }
  }

  static String _fileExtension(String path) {
    final fileName = path.split(RegExp(r'[\\/]')).last;

    final dot = fileName.lastIndexOf('.');

    if (dot <= 0 || dot == fileName.length - 1) {
      return '.jpg';
    }

    final extension = fileName.substring(dot);

    if (extension.length > 6) {
      return '.jpg';
    }

    return extension;
  }

  static Future<void> _deleteStoredImage(String path) async {
    try {
      final docs = await getApplicationDocumentsDirectory();

      final savedDirectory = Directory(
        '${docs.path}${Platform.pathSeparator}'
        'saved_places',
      );

      if (!path.startsWith(savedDirectory.path)) {
        return;
      }

      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Không cần làm app lỗi chỉ vì xóa ảnh thất bại.
    }
  }
}
