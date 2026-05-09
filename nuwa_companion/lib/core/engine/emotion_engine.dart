import 'dart:math' as math;
import '../models/models.dart';
import 'vector_engine.dart';

class EmotionEngine {
  static const List<String> emotions = [
    'joy', 'sadness', 'anger', 'fear', 'surprise',
    'disgust', 'trust', 'anticipation', 'love',
    'regret', 'shame', 'guilt', 'curiosity',
  ];

  static const Map<String, List<String>> emotionCorrelations = {
    'joy': ['surprise', 'trust', 'anticipation'],
    'sadness': ['fear', 'disgust', 'regret'],
    'anger': ['disgust', 'fear'],
    'fear': ['sadness', 'surprise'],
    'surprise': ['joy', 'fear'],
    'disgust': ['anger', 'sadness'],
    'trust': ['joy', 'love'],
    'anticipation': ['joy', 'surprise'],
    'love': ['joy', 'trust', 'anticipation'],
    'regret': ['sadness', 'guilt'],
    'shame': ['sadness', 'guilt', 'fear'],
    'guilt': ['sadness', 'regret', 'shame'],
    'curiosity': ['anticipation', 'surprise'],
  };

  static const Map<String, double> emotionBaseWeights = {
    'joy': 0.5,
    'sadness': 0.3,
    'anger': 0.2,
    'fear': 0.2,
    'surprise': 0.3,
    'disgust': 0.2,
    'trust': 0.5,
    'anticipation': 0.4,
    'love': 0.4,
    'regret': 0.3,
    'shame': 0.2,
    'guilt': 0.2,
    'curiosity': 0.5,
  };

  EmotionalSpectrum updateFromInput(
    EmotionalSpectrum current,
    String input, {
    double intensity = 0.1,
  }) {
    final keywords = _analyzeSentiment(input);
    final updates = <String, double>{};

    for (var entry in keywords.entries) {
      updates[entry.key] = (entry.value * intensity * 0.5).clamp(0.0, 0.3);
    }

    for (var entry in updates.entries) {
      final correlated = emotionCorrelations[entry.key] ?? [];
      for (var corr in correlated) {
        updates[corr] = (updates[corr] ?? 0.0) + (entry.value * 0.3);
      }
    }

    final newValues = <String, double>{};
    for (var emotion in emotions) {
      final currentValue = current[emotion];
      final delta = updates[emotion] ?? 0.0;
      final naturalDecay = (0.5 - currentValue) * 0.02;
      newValues[emotion] = (currentValue + delta + naturalDecay).clamp(0.0, 1.0);
    }

    return current.copyWith(updates: newValues);
  }

  EmotionalSpectrum updateFromResponse(
    EmotionalSpectrum current,
    String response, {
    double intensity = 0.1,
  }) {
    final sentiment = _analyzeSentiment(response);
    final updates = <String, double>{};

    for (var entry in sentiment.entries) {
      updates[entry.key] = (entry.value * intensity * 0.3);
    }

    final newValues = <String, double>{};
    for (var emotion in emotions) {
      final currentValue = current[emotion];
      final delta = updates[emotion] ?? 0.0;
      newValues[emotion] = (currentValue + delta).clamp(0.0, 1.0);
    }

    return current.copyWith(updates: newValues);
  }

  EmotionalSpectrum decay(EmotionalSpectrum current, {double rate = 0.01}) {
    final updates = <String, double>{};
    for (var emotion in emotions) {
      final value = current[emotion];
      final decayAmount = (value - 0.5) * rate;
      updates[emotion] = value - decayAmount;
    }
    return current.copyWith(updates: updates);
  }

  EmotionalSpectrum applyStress(
    EmotionalSpectrum current, {
    double stressLevel = 0.2,
  }) {
    final updates = <String, double>{
      'fear': stressLevel,
      'anxiety': stressLevel,
      'sadness': stressLevel * 0.5,
    };

    final newValues = <String, double>{};
    for (var emotion in emotions) {
      final delta = updates[emotion] ?? 0.0;
      newValues[emotion] = (current[emotion] + delta).clamp(0.0, 1.0);
    }

    return current.copyWith(updates: newValues);
  }

  EmotionalSpectrum applyJoy(
    EmotionalSpectrum current, {
    double joyLevel = 0.2,
  }) {
    final updates = <String, double>{
      'joy': joyLevel,
      'trust': joyLevel * 0.5,
      'anticipation': joyLevel * 0.3,
    };

    final newValues = <String, double>{};
    for (var emotion in emotions) {
      final delta = updates[emotion] ?? 0.0;
      newValues[emotion] = (current[emotion] + delta).clamp(0.0, 1.0);
    }

    return current.copyWith(updates: newValues);
  }

  Map<String, double> _analyzeSentiment(String text) {
    final lowerText = text.toLowerCase();
    final scores = <String, double>{};

    const positivePatterns = {
      'joy': ['开心', '高兴', '快乐', 'happy', 'joy', 'glad', 'pleased', 'delighted', '太好了', '真棒', '喜欢', 'love', 'enjoy'],
      'trust': ['相信', '信任', '相信你', '相信我', 'trust', 'believe', 'rely', '依赖', '依靠'],
      'anticipation': ['期待', '希望', '想', '想要', 'anticipate', 'expect', 'hope', 'look forward', '将要'],
      'love': ['爱', '喜欢', '关心', '在乎', 'love', 'like', 'care', 'adore', '喜欢', '喜欢你'],
      'surprise': ['惊讶', '意外', '吃惊', '震惊', 'surprise', 'amazing', 'wow', '惊讶', '竟然'],
    };

    const negativePatterns = {
      'sadness': ['悲伤', '难过', '伤心', 'sad', 'unhappy', 'depressed', 'sorrow', '难过', '沮丧'],
      'anger': ['生气', '愤怒', '恼火', 'angry', 'mad', 'furious', 'annoyed', '讨厌', '可恶'],
      'fear': ['害怕', '恐惧', '担心', 'fear', 'afraid', 'scared', 'worried', '焦虑', '紧张'],
      'disgust': ['厌恶', '讨厌', '恶心', 'disgust', 'hate', 'dislike', '讨厌', '反感'],
      'regret': ['后悔', '遗憾', '可惜', 'regret', 'sorry', '遗憾', '可惜'],
      'shame': ['羞耻', '丢脸', '惭愧', 'shame', 'embarrassed', 'ashamed', '丢人'],
      'guilt': ['内疚', '愧疚', '自责', 'guilt', 'guilty', 'remorse', '惭愧'],
    };

    for (var entry in positivePatterns.entries) {
      int count = 0;
      for (var pattern in entry.value) {
        if (lowerText.contains(pattern)) {
          count++;
        }
      }
      if (count > 0) {
        scores[entry.key] = (count / entry.value.length).clamp(0.0, 1.0);
      }
    }

    for (var entry in negativePatterns.entries) {
      int count = 0;
      for (var pattern in entry.value) {
        if (lowerText.contains(pattern)) {
          count++;
        }
      }
      if (count > 0) {
        scores[entry.key] = -(count / entry.value.length).clamp(0.0, 1.0);
      }
    }

    if (scores.isEmpty) {
      scores['curiosity'] = 0.1;
    }

    return scores;
  }

  static String getDominantEmotionLabel(EmotionalSpectrum spectrum) {
    final dominant = spectrum.dominantEmotion;
    const labels = {
      'joy': '喜悦',
      'sadness': '悲伤',
      'anger': '愤怒',
      'fear': '恐惧',
      'surprise': '惊讶',
      'disgust': '厌恶',
      'trust': '信任',
      'anticipation': '期待',
      'love': '爱',
      'regret': '遗憾',
      'shame': '羞愧',
      'guilt': '内疚',
      'curiosity': '好奇',
    };
    return labels[dominant] ?? dominant;
  }

  static Map<String, dynamic> analyzeEmotionState(EmotionalSpectrum spectrum) {
    final valence = spectrum.emotionalValence;
    final dominant = spectrum.dominantEmotion;
    final intensity = spectrum.averageIntensity;

    String mood;
    if (valence > 0.3 && intensity > 0.6) {
      mood = '愉悦';
    } else if (valence > 0.3) {
      mood = '积极';
    } else if (valence < -0.3 && intensity > 0.6) {
      mood = '沮丧';
    } else if (valence < -0.3) {
      mood = '消极';
    } else if (intensity > 0.7) {
      mood = '激动';
    } else {
      mood = '平静';
    }

    return {
      'mood': mood,
      'valence': valence,
      'dominant_emotion': dominant,
      'intensity': intensity,
      'is_stable': intensity < 0.7,
      'needs_attention': intensity > 0.8,
    };
  }

  EmotionalSpectrum evolve(EmotionalSpectrum current, {double dt = 0.02}) {
    final updates = <String, double>{};
    
    for (var emotion in emotions) {
      final currentValue = current[emotion];
      final targetValue = emotionBaseWeights[emotion] ?? 0.5;
      
      final diff = targetValue - currentValue;
      updates[emotion] = currentValue + diff * dt;
    }
    
    return current.copyWith(updates: updates);
  }
}
