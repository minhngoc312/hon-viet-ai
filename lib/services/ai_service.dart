import 'dart:convert';

import 'package:http/http.dart' as http;

class HeritageResult {
  final String name;
  final String location;
  final int confidence;
  final String category;
  final String introduction;
  final String history;
  final String architectureCulture;
  final List<String> conservationTips;

  const HeritageResult({
    required this.name,
    required this.location,
    required this.confidence,
    required this.category,
    required this.introduction,
    required this.history,
    required this.architectureCulture,
    required this.conservationTips,
  });

  factory HeritageResult.fromJson(Map<String, dynamic> json) {
    return HeritageResult(
      name: json['name'] ?? 'Không xác định',
      location: json['location'] ?? '',
      confidence: json['confidence'] ?? 0,
      category: json['category'] ?? '',
      introduction: json['introduction'] ?? '',
      history: json['history'] ?? '',
      architectureCulture: json['architecture_culture'] ?? '',
      conservationTips: List<String>.from(json['conservation_tips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'confidence': confidence,
      'category': category,
      'introduction': introduction,
      'history': history,
      'architecture_culture': architectureCulture,
      'conservation_tips': conservationTips,
    };
  }
}

class GuideMessage {
  final String role;
  final String content;

  const GuideMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

class AiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<HeritageResult> identifyHeritage(String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/identify'),
    );

    request.headers['Accept'] = 'application/json';

    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 90),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Server ${response.statusCode}: ${response.body}');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    return HeritageResult.fromJson(data);
  }

  static Future<String> askGuide({
    required HeritageResult heritage,
    required List<GuideMessage> messages,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/chat'),
          headers: const {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'heritage': heritage.toJson(),
            'messages': messages.map((message) => message.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception(
        'Server ${response.statusCode}: '
        '${utf8.decode(response.bodyBytes)}',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final answer = (data['answer'] ?? '').toString().trim();

    if (answer.isEmpty) {
      throw Exception('AI không trả về nội dung.');
    }

    return answer;
  }
}
