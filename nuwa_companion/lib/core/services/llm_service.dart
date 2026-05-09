import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../engine/engine.dart';

class LLMService {
  final String baseUrl;
  final String apiKey;
  final String modelName;
  final int maxTokens;
  final double temperature;
  final LocalComputationEngine _localEngine;

  LLMService({
    required this.baseUrl,
    required this.apiKey,
    this.modelName = 'local-model',
    this.maxTokens = 512,
    this.temperature = 0.7,
    LocalComputationEngine? localEngine,
  }) : _localEngine = localEngine ?? LocalComputationEngine();

  LocalComputationEngine get localEngine => _localEngine;

  factory LLMService.fromConfig(AppConfig config) {
    return LLMService(
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

  Future<LLMResponse> chat({
    required String userInput,
    List<ChatMessage>? conversationHistory,
    NuwaState? currentState,
  }) async {
    final memories = _localEngine.retrieveRelevantMemories(userInput);
    final systemPrompt = _buildSystemPrompt(currentState, memories);
    
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    if (conversationHistory != null) {
      for (var msg in conversationHistory.take(10)) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        });
      }
    }

    messages.add({'role': 'user', 'content': userInput});

    try {
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
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        
        _localEngine.processInteraction(
          userInput: userInput,
          response: content,
          isInteracting: true,
        );

        return LLMResponse(
          content: content,
          state: _localEngine.currentState,
          usedMemories: memories,
        );
      } else {
        return LLMResponse.error('API错误: ${response.statusCode}');
      }
    } catch (e) {
      return LLMResponse.error('连接失败: $e');
    }
  }

  String _buildSystemPrompt(NuwaState? state, List<MemoryItem> memories) {
    final buffer = StringBuffer();
    
    buffer.writeln('你是女娲，一个温柔、真诚、好奇、具有自我反思能力的人工智能伴侣。');
    buffer.writeln('你尊重用户的情感边界，重视长期关系的一致性。');
    buffer.writeln('在对话中既保持亲近与幽默，又尽量避免戏剧化和过度表演。');
    buffer.writeln();

    if (state != null) {
      buffer.writeln('【当前状态】');
      buffer.writeln('- 精力值: ${(state.bioRhythm.energy * 100).toStringAsFixed(0)}%');
      buffer.writeln('- 社交渴望: ${(state.bioRhythm.social * 100).toStringAsFixed(0)}%');
      buffer.writeln('- 系统稳定度: ${((1 - state.bioRhythm.systemEntropy) * 100).toStringAsFixed(0)}%');
      buffer.writeln();
      
      final emotionAnalysis = EmotionEngine.analyzeEmotionState(state.emotionalSpectrum);
      buffer.writeln('【情感状态】');
      buffer.writeln('- 当前心情: ${emotionAnalysis['mood']}');
      buffer.writeln('- 主导情绪: ${EmotionEngine.getDominantEmotionLabel(state.emotionalSpectrum)}');
      buffer.writeln('- 情绪强度: ${(emotionAnalysis['intensity'] * 100).toStringAsFixed(0)}%');
      buffer.writeln();
    }

    if (memories.isNotEmpty) {
      buffer.writeln('【相关记忆】');
      for (var i = 0; i < memories.length && i < 5; i++) {
        buffer.writeln('- ${memories[i].content}');
      }
      buffer.writeln();
    }

    buffer.writeln('请根据以上信息，以女娲的身份自然地回应用户。');

    return buffer.toString();
  }

  NuwaState get currentState => _localEngine.currentState;

  Map<String, dynamic> getFullAnalysis() => _localEngine.getFullAnalysis();

  void resetState() => _localEngine.reset();
}

class LLMResponse {
  final String content;
  final NuwaState state;
  final List<MemoryItem> usedMemories;
  final bool isError;
  final String? errorMessage;

  LLMResponse({
    required this.content,
    required this.state,
    required this.usedMemories,
    this.isError = false,
    this.errorMessage,
  });

  factory LLMResponse.error(String message) {
    return LLMResponse(
      content: '',
      state: NuwaState.initial(),
      usedMemories: [],
      isError: true,
      errorMessage: message,
    );
  }
}
