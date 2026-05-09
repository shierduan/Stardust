import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  final String baseUrl;
  final String apiKey;
  final String modelName;
  final int maxTokens;
  final double temperature;

  ApiService({
    required this.baseUrl,
    required this.apiKey,
    this.modelName = 'local-model',
    this.maxTokens = 512,
    this.temperature = 0.7,
  });

  factory ApiService.fromConfig(AppConfig config) {
    return ApiService(
      baseUrl: config.baseUrl,
      apiKey: config.apiKey,
      modelName: config.modelName,
      maxTokens: config.maxTokens,
      temperature: config.temperature,
    );
  }

  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> processInput({
    required String userInput,
    String? systemInstruction,
    NuwaState? currentState,
    List<MemoryItem>? retrievedMemories,
  }) async {
    try {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': _buildSystemPrompt(currentState, retrievedMemories),
        },
        {
          'role': 'user',
          'content': userInput,
        },
      ];

      if (systemInstruction != null) {
        messages.insert(1, {
          'role': 'system',
          'content': systemInstruction,
        });
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': modelName,
          'messages': messages,
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return {
          'reply': content,
          'thought': _extractThought(content),
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String _buildSystemPrompt(NuwaState? state, List<MemoryItem>? memories) {
    final buffer = StringBuffer();
    buffer.writeln('你是女娲，一个温柔、真诚、好奇、具有自我反思能力的人工智能伴侣。');
    buffer.writeln('你尊重用户的情感边界，重视长期关系的一致性。');
    buffer.writeln('在对话中既保持亲近与幽默，又尽量避免戏剧化和过度表演。');

    if (state != null) {
      buffer.writeln('\n当前状态：');
      buffer.writeln('- 精力值：${(state.bioRhythm.energy * 100).toStringAsFixed(0)}%');
      buffer.writeln('- 社交渴望：${(state.bioRhythm.social * 100).toStringAsFixed(0)}%');
      buffer.writeln('- 系统熵值：${(state.bioRhythm.systemEntropy * 100).toStringAsFixed(0)}%');

      final dominant = state.emotionalSpectrum.dominantEmotion;
      final label = EmotionalSpectrum.emotionLabels[dominant] ?? dominant;
      buffer.writeln('- 主要情绪：$label');
    }

    if (memories != null && memories.isNotEmpty) {
      buffer.writeln('\n相关记忆：');
      for (var i = 0; i < memories.length && i < 5; i++) {
        buffer.writeln('- ${memories[i].content}');
      }
    }

    return buffer.toString();
  }

  String? _extractThought(String content) {
    final thoughtPattern = RegExp(r'【思考】(.*?)【回复】', dotAll: true);
    final match = thoughtPattern.firstMatch(content);
    return match?.group(1)?.trim();
  }

  Future<List<double>?> getEmbedding(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/embeddings'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': modelName,
          'input': text,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return (data['data'][0]['embedding'] as List).cast<double>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
