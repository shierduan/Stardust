class EmotionalSpectrum {
  static const List<String> emotions = [
    'joy',
    'sadness', 
    'anger',
    'fear',
    'surprise',
    'disgust',
    'trust',
    'anticipation',
    'love',
    'regret',
    'shame',
    'guilt',
    'curiosity',
  ];

  static const Map<String, String> emotionLabels = {
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

  static const Map<String, String> emotionEmojis = {
    'joy': '😊',
    'sadness': '😢',
    'anger': '😠',
    'fear': '😨',
    'surprise': '😲',
    'disgust': '🤢',
    'trust': '🤝',
    'anticipation': '🤔',
    'love': '❤️',
    'regret': '😔',
    'shame': '😳',
    'guilt': '😣',
    'curiosity': '🧐',
  };

  final Map<String, double> _values;

  EmotionalSpectrum({Map<String, double>? initialValues})
      : _values = initialValues ?? {} {
    for (var emotion in emotions) {
      _values.putIfAbsent(emotion, () => 0.5);
    }
  }

  double operator [](String emotion) => _values[emotion] ?? 0.5;
  
  void operator []=(String emotion, double value) {
    _values[emotion] = value.clamp(0.0, 1.0);
  }

  Map<String, double> get values => Map.unmodifiable(_values);

  double get joy => _values['joy'] ?? 0.5;
  double get sadness => _values['sadness'] ?? 0.5;
  double get anger => _values['anger'] ?? 0.5;
  double get fear => _values['fear'] ?? 0.5;
  double get surprise => _values['surprise'] ?? 0.5;
  double get disgust => _values['disgust'] ?? 0.5;
  double get trust => _values['trust'] ?? 0.5;
  double get anticipation => _values['anticipation'] ?? 0.5;
  double get love => _values['love'] ?? 0.5;
  double get regret => _values['regret'] ?? 0.5;
  double get shame => _values['shame'] ?? 0.5;
  double get guilt => _values['guilt'] ?? 0.5;
  double get curiosity => _values['curiosity'] ?? 0.5;

  String get dominantEmotion {
    String dominant = emotions[0];
    double maxValue = _values[dominant] ?? 0;
    for (var entry in _values.entries) {
      if (entry.value > maxValue) {
        maxValue = entry.value;
        dominant = entry.key;
      }
    }
    return dominant;
  }

  double get averageIntensity {
    if (_values.isEmpty) return 0.5;
    return _values.values.reduce((a, b) => a + b) / _values.length;
  }

  double get emotionalValence {
    double positive = (joy + trust + love + anticipation + surprise) / 5;
    double negative = (sadness + anger + fear + disgust + guilt + shame + regret) / 7;
    return positive - negative;
  }

  void updateFromMap(Map<String, double> updates) {
    for (var entry in updates.entries) {
      if (emotions.contains(entry.key)) {
        _values[entry.key] = entry.value.clamp(0.0, 1.0);
      }
    }
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_values);

  factory EmotionalSpectrum.fromJson(Map<String, dynamic> json) {
    final values = <String, double>{};
    for (var emotion in emotions) {
      values[emotion] = (json[emotion] as num?)?.toDouble() ?? 0.5;
    }
    return EmotionalSpectrum(initialValues: values);
  }

  EmotionalSpectrum copyWith({Map<String, double>? updates}) {
    final newValues = Map<String, double>.from(_values);
    if (updates != null) {
      newValues.addAll(updates);
    }
    return EmotionalSpectrum(initialValues: newValues);
  }

  List<MapEntry<String, double>> get sortedByIntensity {
    final entries = _values.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}
