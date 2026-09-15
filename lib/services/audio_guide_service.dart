import 'package:flutter_tts/flutter_tts.dart';

import 'ai_service.dart';

class AudioGuideService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await _tts.setLanguage('vi-VN');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _initialized = true;
  }

  static Future<void> speakText(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await _ensureInitialized();
    await _tts.stop();
    await _tts.speak(cleanText);
  }

  static Future<void> speakFullGuide(HeritageResult result) async {
    final sections = <String>[
      result.name,
      if (result.location.trim().isNotEmpty) 'Địa điểm: ${result.location}.',
      if (result.introduction.trim().isNotEmpty)
        'Giới thiệu. ${result.introduction}',
      if (result.history.trim().isNotEmpty) 'Lịch sử. ${result.history}',
      if (result.architectureCulture.trim().isNotEmpty)
        'Kiến trúc và văn hóa. ${result.architectureCulture}',
      if (result.conservationTips.isNotEmpty)
        'Lưu ý khi tham quan. ${result.conservationTips.join('. ')}',
    ];

    await speakText(sections.join(' '));
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}
