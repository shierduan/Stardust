import 'emotional_spectrum.dart';
import 'bio_rhythm.dart';
import 'memory_item.dart';

class NuwaState {
  final EmotionalSpectrum emotionalSpectrum;
  final BioRhythm bioRhythm;
  final List<MemoryItem> recentMemories;
  final double evolutionLevel;
  final double experience;
  final double lastInteractionTimestamp;
  final String? currentThought;

  const NuwaState({
    required this.emotionalSpectrum,
    required this.bioRhythm,
    required this.recentMemories,
    required this.evolutionLevel,
    required this.experience,
    required this.lastInteractionTimestamp,
    this.currentThought,
  });

  factory NuwaState.initial() {
    return NuwaState(
      emotionalSpectrum: EmotionalSpectrum(),
      bioRhythm: BioRhythm.initial(),
      recentMemories: const [],
      evolutionLevel: 1.0,
      experience: 0.0,
      lastInteractionTimestamp: DateTime.now().millisecondsSinceEpoch / 1000,
      currentThought: null,
    );
  }

  bool get isHealthy => bioRhythm.isHealthy;

  String get overallStatus {
    if (bioRhythm.needsRest) return '需要休息';
    if (bioRhythm.needsInteraction) return '渴望交流';
    if (!isHealthy) return '状态异常';
    return '状态良好';
  }

  String get moodDescription {
    final dominant = emotionalSpectrum.dominantEmotion;
    final label = EmotionalSpectrum.emotionLabels[dominant] ?? dominant;
    final valence = emotionalSpectrum.emotionalValence;
    
    if (valence > 0.3) return '心情愉悦';
    if (valence < -0.3) return '情绪低落';
    return '情绪平静';
  }

  NuwaState copyWith({
    EmotionalSpectrum? emotionalSpectrum,
    BioRhythm? bioRhythm,
    List<MemoryItem>? recentMemories,
    double? evolutionLevel,
    double? experience,
    double? lastInteractionTimestamp,
    String? currentThought,
  }) {
    return NuwaState(
      emotionalSpectrum: emotionalSpectrum ?? this.emotionalSpectrum,
      bioRhythm: bioRhythm ?? this.bioRhythm,
      recentMemories: recentMemories ?? this.recentMemories,
      evolutionLevel: evolutionLevel ?? this.evolutionLevel,
      experience: experience ?? this.experience,
      lastInteractionTimestamp: lastInteractionTimestamp ?? this.lastInteractionTimestamp,
      currentThought: currentThought ?? this.currentThought,
    );
  }

  Map<String, dynamic> toJson() => {
    'emotional_spectrum': emotionalSpectrum.toJson(),
    'bio_rhythm': bioRhythm.toJson(),
    'recent_memories': recentMemories.map((m) => m.toJson()).toList(),
    'evolution_level': evolutionLevel,
    'experience': experience,
    'last_interaction_timestamp': lastInteractionTimestamp,
    'current_thought': currentThought,
  };

  factory NuwaState.fromJson(Map<String, dynamic> json) {
    return NuwaState(
      emotionalSpectrum: EmotionalSpectrum.fromJson(
        json['emotional_spectrum'] as Map<String, dynamic>? ?? {},
      ),
      bioRhythm: BioRhythm.fromJson(
        json['bio_rhythm'] as Map<String, dynamic>? ?? {},
      ),
      recentMemories: (json['recent_memories'] as List?)
              ?.map((m) => MemoryItem.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      evolutionLevel: (json['evolution_level'] as num?)?.toDouble() ?? 1.0,
      experience: (json['experience'] as num?)?.toDouble() ?? 0.0,
      lastInteractionTimestamp:
          (json['last_interaction_timestamp'] as num?)?.toDouble() ??
              DateTime.now().millisecondsSinceEpoch / 1000,
      currentThought: json['current_thought'] as String?,
    );
  }
}
