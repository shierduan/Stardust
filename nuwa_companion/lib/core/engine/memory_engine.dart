import 'dart:math' as math;
import '../models/models.dart';
import 'vector_engine.dart';

class LocalMemoryEngine {
  final List<MemoryItem> _memories = [];
  final Map<String, List<double>> _memoryVectors = {};
  final int maxMemories;

  LocalMemoryEngine({this.maxMemories = 1000});

  List<MemoryItem> get memories => List.unmodifiable(_memories);
  int get memoryCount => _memories.length;

  String storeMemory(
    String content, {
    double importance = 0.5,
    Map<String, dynamic>? metadata,
    String? emotionContext,
  }) {
    final id = _generateId();
    final vector = LocalVectorEngine.generateVector(content);
    
    final memory = MemoryItem(
      id: id,
      content: content,
      timestamp: DateTime.now(),
      importance: importance,
      metadata: metadata,
      emotionContext: emotionContext,
      vector: vector,
    );
    
    _memories.insert(0, memory);
    _memoryVectors[id] = vector;
    
    _pruneOldMemories();
    
    return id;
  }

  List<MemoryItem> retrieve(
    String query, {
    int topK = 5,
    double minSimilarity = 0.3,
    bool useEmotionFilter = false,
    String? emotionFilter,
  }) {
    final queryVector = LocalVectorEngine.generateVector(query);
    
    final scoredMemories = <(MemoryItem, double)>[];
    
    for (var memory in _memories) {
      double score = _calculateRelevanceScore(memory, queryVector, query);
      
      if (useEmotionFilter && emotionFilter != null) {
        if (memory.emotionContext != emotionFilter) {
          score *= 0.5;
        }
      }
      
      if (score >= minSimilarity) {
        scoredMemories.add((memory, score));
      }
    }
    
    scoredMemories.sort((a, b) => b.$2.compareTo(a.$2));
    
    return scoredMemories.take(topK).map((e) => e.$1).toList();
  }

  double _calculateRelevanceScore(
    MemoryItem memory,
    List<double> queryVector,
    String query,
  ) {
    double vectorScore = 0.0;
    if (memory.vector != null) {
      vectorScore = LocalVectorEngine.cosineSimilarity(queryVector, memory.vector!);
    }
    
    double textScore = _calculateTextSimilarity(query, memory.content);
    
    double importanceWeight = 0.3;
    double importanceBonus = memory.importance * importanceWeight;
    
    double recencyWeight = 0.2;
    double recencyScore = _calculateRecencyScore(memory.timestamp);
    double recencyBonus = recencyScore * recencyWeight;
    
    double finalScore = (vectorScore * 0.5) + 
                        (textScore * 0.3) + 
                        importanceBonus + 
                        recencyBonus;
    
    return finalScore.clamp(0.0, 1.0);
  }

  double _calculateTextSimilarity(String a, String b) {
    final wordsA = _tokenize(a);
    final wordsB = _tokenize(b);
    
    if (wordsA.isEmpty || wordsB.isEmpty) return 0.0;
    
    int commonWords = 0;
    for (var word in wordsA) {
      if (wordsB.contains(word)) {
        commonWords++;
      }
    }
    
    final jaccard = commonWords / (wordsA.length + wordsB.length - commonWords);
    final dice = (2 * commonWords) / (wordsA.length + wordsB.length);
    
    return (jaccard + dice) / 2;
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u4e00-\u9fff]'), ' ')
        .split(RegExp(r'\s+'))
        .where((s) => s.length > 1)
        .toSet()
        .toList();
  }

  double _calculateRecencyScore(DateTime timestamp) {
    final age = DateTime.now().difference(timestamp);
    final maxAge = const Duration(days: 30);
    
    if (age.inHours < 1) return 1.0;
    if (age > maxAge) return 0.1;
    
    return 1.0 - (age.inHours / maxAge.inHours);
  }

  List<MemoryItem> getRecentMemories({int limit = 10}) {
    return _memories.take(limit).toList();
  }

  List<MemoryItem> getHighImportanceMemories({int limit = 20}) {
    final sorted = List<MemoryItem>.from(_memories);
    sorted.sort((a, b) => b.importance.compareTo(a.importance));
    return sorted.take(limit).toList();
  }

  List<MemoryItem> getEmotionContextMemories(String emotionContext, {int limit = 10}) {
    return _memories
        .where((m) => m.emotionContext == emotionContext)
        .take(limit)
        .toList();
  }

  MemoryItem? getMemory(String id) {
    try {
      return _memories.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateMemory(String id, {double? importance, String? content}) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      final old = _memories[index];
      _memories[index] = old.copyWith(
        importance: importance ?? old.importance,
        content: content ?? old.content,
      );
    }
  }

  bool deleteMemory(String id) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      _memories.removeAt(index);
      _memoryVectors.remove(id);
      return true;
    }
    return false;
  }

  void _pruneOldMemories() {
    while (_memories.length > maxMemories) {
      final lowestImportance = _memories.last;
      if (lowestImportance.importance < 0.3) {
        _memories.removeLast();
        _memoryVectors.remove(lowestImportance.id);
      } else {
        final oldest = _memories.last;
        _memories.removeLast();
        _memoryVectors.remove(oldest.id);
      }
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(10000)}';
  }

  Map<String, dynamic> getMemoryStats() {
    if (_memories.isEmpty) {
      return {
        'total': 0,
        'high_importance': 0,
        'avg_importance': 0.0,
        'oldest': null,
        'newest': null,
      };
    }

    final highImportance = _memories.where((m) => m.importance > 0.7).length;
    final avgImportance = _memories.map((m) => m.importance).reduce((a, b) => a + b) / _memories.length;

    return {
      'total': _memories.length,
      'high_importance': highImportance,
      'avg_importance': avgImportance,
      'oldest': _memories.last.timestamp,
      'newest': _memories.first.timestamp,
    };
  }

  void consolidate(double threshold = 0.9) {
    final toRemove = <String>[];
    
    for (int i = 0; i < _memories.length; i++) {
      for (int j = i + 1; j < _memories.length; j++) {
        if (toRemove.contains(_memories[j].id)) continue;
        
        final similarity = _calculateTextSimilarity(
          _memories[i].content,
          _memories[j].content,
        );
        
        if (similarity > threshold) {
          if (_memories[i].importance >= _memories[j].importance) {
            toRemove.add(_memories[j].id);
          } else {
            toRemove.add(_memories[i].id);
            break;
          }
        }
      }
    }
    
    _memories.removeWhere((m) => toRemove.contains(m.id));
    for (var id in toRemove) {
      _memoryVectors.remove(id);
    }
  }

  void clear() {
    _memories.clear();
    _memoryVectors.clear();
  }

  Map<String, dynamic> toJson() {
    return {
      'memories': _memories.map((m) => m.toJson()).toList(),
      'max_memories': maxMemories,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    clear();
    final memoriesJson = json['memories'] as List? ?? [];
    for (var m in memoriesJson) {
      final memory = MemoryItem.fromJson(m as Map<String, dynamic>);
      _memories.add(memory);
      if (memory.vector != null) {
        _memoryVectors[memory.id] = memory.vector!;
      }
    }
  }
}
