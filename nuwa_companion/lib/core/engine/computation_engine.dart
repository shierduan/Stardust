import 'dart:math' as math;
import '../models/models.dart';
import 'vector_engine.dart';
import 'semantic_field.dart';
import 'pid_controller.dart';
import 'memory_engine.dart';
import 'emotion_engine.dart';

class LocalComputationEngine {
  late VectorEngine _vectorEngine;
  late SemanticFieldManager _semanticField;
  late BioRhythmController _bioController;
  late LocalMemoryEngine _memoryEngine;
  late EmotionEngine _emotionEngine;
  
  NuwaState _currentState;
  final List<NuwaState> _stateHistory = [];
  final int maxHistorySize;

  LocalComputationEngine({
    List<double>? corePersonality,
    this.maxHistorySize = 50,
  }) : _currentState = NuwaState.initial() {
    _initialize(corePersonality ?? _generateDefaultPersonality());
  }

  void _initialize(List<double> corePersonality) {
    _vectorEngine = VectorEngine();
    _semanticField = SemanticFieldManager(corePersonality: corePersonality);
    _bioController = BioRhythmController();
    _memoryEngine = LocalMemoryEngine();
    _emotionEngine = EmotionEngine();
  }

  List<double> _generateDefaultPersonality() {
    return VectorEngine.generateVector(
      '温柔、真诚、好奇、具有自我反思能力的人工智能伴侣'
    );
  }

  NuwaState get currentState => _currentState;

  NuwaState processInteraction({
    required String userInput,
    String? response,
    bool isInteracting = true,
  }) {
    _stateHistory.add(_currentState);
    if (_stateHistory.length > maxHistorySize) {
      _stateHistory.removeAt(0);
    }

    final queryVector = VectorEngine.generateVector(userInput);
    final semanticMetrics = _semanticField.computeSemanticMetrics(queryVector);
    
    final newEmotionSpectrum = _emotionEngine.updateFromInput(
      _currentState.emotionalSpectrum,
      userInput,
      intensity: 0.15,
    );

    if (response != null) {
      _emotionEngine.updateFromResponse(
        newEmotionSpectrum,
        response,
        intensity: 0.1,
      );
    }

    _memoryEngine.storeMemory(
      userInput,
      importance: _calculateImportance(userInput),
      emotionContext: _emotionEngine.getDominantEmotionLabel(newEmotionSpectrum),
    );

    if (response != null) {
      _memoryEngine.storeMemory(
        '我回应: $response',
        importance: 0.6,
        emotionContext: '回复',
      );
    }

    final bioUpdate = _bioController.update(
      currentEnergy: _currentState.bioRhythm.energy,
      currentSocial: _currentState.bioRhythm.social,
      currentEntropy: _currentState.bioRhythm.systemEntropy,
      isInteracting: isInteracting,
      isResting: _currentState.bioRhythm.needsRest,
      interactionIntensity: semanticMetrics['similarity'] ?? 0.5,
    );

    final evolvedState = _semanticField.evolveState(iterations: 10);
    final evolvedEmotion = _emotionEngine.evolve(_currentState.emotionalSpectrum);

    _currentState = _currentState.copyWith(
      emotionalSpectrum: newEmotionSpectrum,
      bioRhythm: BioRhythm(
        energy: bioUpdate['energy']!,
        social: bioUpdate['social']!,
        systemEntropy: bioUpdate['entropy']!,
        lastUpdateTimestamp: DateTime.now().millisecondsSinceEpoch / 1000,
      ),
      recentMemories: _memoryEngine.getRecentMemories(limit: 10),
      lastInteractionTimestamp: DateTime.now().millisecondsSinceEpoch / 1000,
    );

    return _currentState;
  }

  double _calculateImportance(String text) {
    final words = text.split(RegExp(r'\s+'));
    double importance = 0.5;

    if (words.length > 20) importance += 0.1;
    if (text.contains('记住') || text.contains('重要')) importance += 0.2;
    if (text.contains('名字') || text.contains('生日')) importance += 0.3;
    if (text.contains('喜欢') || text.contains('讨厌')) importance += 0.15;

    final emotion = _emotionEngine.updateFromInput(
      _currentState.emotionalSpectrum,
      text,
      intensity: 0.1,
    );
    if (emotion.emotionalValence.abs() > 0.3) {
      importance += 0.1;
    }

    return importance.clamp(0.0, 1.0);
  }

  List<MemoryItem> retrieveRelevantMemories(String query, {int topK = 5}) {
    return _memoryEngine.retrieve(query, topK: topK);
  }

  Map<String, dynamic> getSemanticAnalysis(String text) {
    final vector = VectorEngine.generateVector(text);
    return _semanticField.computeSemanticMetrics(vector);
  }

  BioRhythm updateBioRhythm({
    required bool isInteracting,
    required bool isResting,
  }) {
    final bioUpdate = _bioController.update(
      currentEnergy: _currentState.bioRhythm.energy,
      currentSocial: _currentState.bioRhythm.social,
      currentEntropy: _currentState.bioRhythm.systemEntropy,
      isInteracting: isInteracting,
      isResting: isResting,
      interactionIntensity: 0.5,
    );

    _currentState = _currentState.copyWith(
      bioRhythm: BioRhythm(
        energy: bioUpdate['energy']!,
        social: bioUpdate['social']!,
        systemEntropy: bioUpdate['entropy']!,
        lastUpdateTimestamp: DateTime.now().millisecondsSinceEpoch / 1000,
      ),
    );

    return _currentState.bioRhythm;
  }

  EmotionalSpectrum evolveEmotions() {
    final evolved = _emotionEngine.evolve(_currentState.emotionalSpectrum);
    _currentState = _currentState.copyWith(emotionalSpectrum: evolved);
    return evolved;
  }

  Map<String, dynamic> getFullAnalysis() {
    return {
      'semantic_field': _semanticField.analyzeCurrentState(),
      'bio_rhythm': {
        'energy': _currentState.bioRhythm.energy,
        'social': _currentState.bioRhythm.social,
        'entropy': _currentState.bioRhythm.systemEntropy,
        'status': _currentState.bioRhythm.energyStatus,
      },
      'emotion': EmotionEngine.analyzeEmotionState(_currentState.emotionalSpectrum),
      'memory_stats': _memoryEngine.getMemoryStats(),
      'state_stability': _calculateStability(),
    };
  }

  double _calculateStability() {
    if (_stateHistory.length < 2) return 1.0;

    double totalDrift = 0.0;
    for (int i = 1; i < _stateHistory.length; i++) {
      final prev = _stateHistory[i - 1].emotionalSpectrum;
      final curr = _stateHistory[i].emotionalSpectrum;

      double drift = 0.0;
      for (var emotion in EmotionEngine.emotions) {
        drift += (prev[emotion] - curr[emotion]).abs();
      }
      totalDrift += drift / EmotionEngine.emotions.length;
    }

    return (1.0 - totalDrift / _stateHistory.length).clamp(0.0, 1.0);
  }

  void reset() {
    _currentState = NuwaState.initial();
    _stateHistory.clear();
    _bioController.reset();
    _memoryEngine.clear();
  }

  Map<String, dynamic> toJson() {
    return {
      'current_state': _currentState.toJson(),
      'state_history': _stateHistory.map((s) => s.toJson()).toList(),
      'memory_engine': _memoryEngine.toJson(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _currentState = NuwaState.fromJson(json['current_state']);
    _memoryEngine.fromJson(json['memory_engine'] ?? {});
  }
}

class VectorEngine {
  static const int vectorDimension = 64;

  static List<double> generateVector(String text) {
    return LocalVectorEngine.generateVector(text);
  }

  static double cosineSimilarity(List<double> a, List<double> b) {
    return LocalVectorEngine.cosineSimilarity(a, b);
  }

  static double euclideanDistance(List<double> a, List<double> b) {
    return LocalVectorEngine.euclideanDistance(a, b);
  }
}
