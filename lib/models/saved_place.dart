import '../services/ai_service.dart';

class SavedPlace {
  final String id;
  final String imagePath;
  final HeritageResult result;
  final DateTime savedAt;

  const SavedPlace({
    required this.id,
    required this.imagePath,
    required this.result,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'result': result.toJson(),
      'saved_at': savedAt.toIso8601String(),
    };
  }

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: (json['id'] ?? '').toString(),
      imagePath: (json['image_path'] ?? '').toString(),
      result: HeritageResult.fromJson(
        Map<String, dynamic>.from(json['result'] as Map? ?? {}),
      ),
      savedAt:
          DateTime.tryParse((json['saved_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
