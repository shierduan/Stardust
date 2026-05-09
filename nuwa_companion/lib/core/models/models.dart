import 'emotional_spectrum.dart';
import 'bio_rhythm.dart';
import 'memory_item.dart';
import 'chat_message.dart';

export 'emotional_spectrum.dart';
export 'bio_rhythm.dart';
export 'memory_item.dart';
export 'nuwa_state.dart';
export 'chat_message.dart';

class CompanionConfig {
  final String name;
  final String personality;
  final String avatarUrl;
  final bool showThoughtBubble;
  final bool enableEmotionAnimation;

  const CompanionConfig({
    this.name = '女娲',
    this.personality = '温柔、真诚、好奇、具有自我反思能力',
    this.avatarUrl = '',
    this.showThoughtBubble = true,
    this.enableEmotionAnimation = true,
  });

  CompanionConfig copyWith({
    String? name,
    String? personality,
    String? avatarUrl,
    bool? showThoughtBubble,
    bool? enableEmotionAnimation,
  }) {
    return CompanionConfig(
      name: name ?? this.name,
      personality: personality ?? this.personality,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      showThoughtBubble: showThoughtBubble ?? this.showThoughtBubble,
      enableEmotionAnimation: enableEmotionAnimation ?? this.enableEmotionAnimation,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'personality': personality,
    'avatar_url': avatarUrl,
    'show_thought_bubble': showThoughtBubble,
    'enable_emotion_animation': enableEmotionAnimation,
  };

  factory CompanionConfig.fromJson(Map<String, dynamic> json) {
    return CompanionConfig(
      name: json['name'] as String? ?? '女娲',
      personality: json['personality'] as String? ?? '温柔、真诚、好奇、具有自我反思能力',
      avatarUrl: json['avatar_url'] as String? ?? '',
      showThoughtBubble: json['show_thought_bubble'] as bool? ?? true,
      enableEmotionAnimation: json['enable_emotion_animation'] as bool? ?? true,
    );
  }
}

class AppConfig {
  final String baseUrl;
  final String apiKey;
  final String modelName;
  final int maxTokens;
  final double temperature;
  final bool enableCache;

  const AppConfig({
    this.baseUrl = 'http://127.0.0.1:1234/v1',
    this.apiKey = 'lm-studio',
    this.modelName = 'local-model',
    this.maxTokens = 512,
    this.temperature = 0.7,
    this.enableCache = true,
  });

  AppConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? modelName,
    int? maxTokens,
    double? temperature,
    bool? enableCache,
  }) {
    return AppConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      enableCache: enableCache ?? this.enableCache,
    );
  }

  Map<String, dynamic> toJson() => {
    'base_url': baseUrl,
    'api_key': apiKey,
    'model_name': modelName,
    'max_tokens': maxTokens,
    'temperature': temperature,
    'enable_cache': enableCache,
  };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      baseUrl: json['base_url'] as String? ?? 'http://127.0.0.1:1234/v1',
      apiKey: json['api_key'] as String? ?? 'lm-studio',
      modelName: json['model_name'] as String? ?? 'local-model',
      maxTokens: json['max_tokens'] as int? ?? 512,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      enableCache: json['enable_cache'] as bool? ?? true,
    );
  }
}
