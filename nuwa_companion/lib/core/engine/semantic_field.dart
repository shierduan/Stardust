import 'dart:math' as math;
import 'vector_engine.dart';

class RiemannianSemanticField {
  List<double> coreVector;
  final double curvature;
  final double learningRate;

  RiemannianSemanticField({
    required this.coreVector,
    this.curvature = 0.1,
    this.learningRate = 0.02,
  });

  double calculatePotentialEnergy(List<double> stateVector) {
    final distance = LocalVectorEngine.euclideanDistance(stateVector, coreVector);
    return distance * distance / 2.0;
  }

  List<double> computeRiemannianGradient(List<double> stateVector) {
    final scaledCore = LocalVectorEngine.scaleVector(coreVector, curvature);
    final diff = LocalVectorEngine.subtractVectors(stateVector, scaledCore);
    
    double distance = 0.0;
    for (var v in diff) {
      distance += v * v;
    }
    distance = math.sqrt(distance);
    
    if (distance < 1e-10) {
      return List.filled(stateVector.length, 0.0);
    }
    
    final gradient = diff.map((v) => v / distance).toList();
    return LocalVectorEngine.scaleVector(gradient, learningRate);
  }

  List<double> evolve(List<double> stateVector, {double dt = 0.02, int iterations = 20}) {
    var current = List<double>.from(stateVector);
    
    for (int i = 0; i < iterations; i++) {
      final gradient = computeRiemannianGradient(current);
      
      for (int j = 0; j < current.length; j++) {
        current[j] -= gradient[j] * dt;
      }
      
      current = LocalVectorEngine.addVectors(
        current,
        LocalVectorEngine.subtractVectors(coreVector, current),
      );
    }
    
    return current;
  }

  double computeSemanticDrift(List<double> initial, List<double> current) {
    final distance = LocalVectorEngine.euclideanDistance(initial, current);
    return distance / (1.0 + distance);
  }

  Map<String, dynamic> analyzeDeviation(List<double> stateVector) {
    final energy = calculatePotentialEnergy(stateVector);
    final distance = LocalVectorEngine.euclideanDistance(stateVector, coreVector);
    final gradient = computeRiemannianGradient(stateVector);
    
    return {
      'potential_energy': energy,
      'distance_from_core': distance,
      'gradient_magnitude': math.sqrt(
        gradient.fold(0.0, (sum, v) => sum + v * v)
      ),
      'is_stable': energy < 0.5,
      'needs_correction': energy > 0.8,
    };
  }

  List<double> projectOntoManifold(List<double> vector) {
    final distance = LocalVectorEngine.euclideanDistance(vector, coreVector);
    final normalized = LocalVectorEngine.scaleVector(
      LocalVectorEngine.subtractVectors(vector, coreVector),
      curvature / (curvature + distance),
    );
    return LocalVectorEngine.addVectors(coreVector, normalized);
  }

  double computeCurvaturePenalty(List<double> stateVector) {
    final distance = LocalVectorEngine.euclideanDistance(stateVector, coreVector);
    return curvature * distance * distance;
  }

  Map<String, double> computeDirectionalTensions(List<double> stateVector) {
    final diff = LocalVectorEngine.subtractVectors(stateVector, coreVector);
    
    return {
      'tension_x': diff.isNotEmpty ? diff[0] : 0.0,
      'tension_y': diff.length > 1 ? diff[1] : 0.0,
      'tension_z': diff.length > 2 ? diff[2] : 0.0,
    };
  }
}

class SemanticFieldManager {
  final Map<String, RiemannianSemanticField> _fields = {};
  List<double> _currentState;

  SemanticFieldManager({
    required List<double> corePersonality,
    double curvature = 0.1,
  }) : _currentState = corePersonality {
    _fields['personality'] = RiemannianSemanticField(
      coreVector: corePersonality,
      curvature: curvature,
    );
    
    _fields['emotion'] = RiemannianSemanticField(
      coreVector: _generateEmotionCore(),
      curvature: curvature * 1.5,
    );
    
    _fields['social'] = RiemannianSemanticField(
      coreVector: _generateSocialCore(),
      curvature: curvature * 0.8,
    );
  }

  List<double> _generateEmotionCore() {
    final vector = List<double>.filled(64, 0.0);
    for (int i = 0; i < vector.length; i++) {
      vector[i] = math.sin(i * 0.1) * 0.5;
    }
    return LocalVectorEngine._normalize(vector);
  }

  List<double> _generateSocialCore() {
    final vector = List<double>.filled(64, 0.0);
    for (int i = 0; i < vector.length; i++) {
      vector[i] = math.cos(i * 0.15) * 0.5;
    }
    return LocalVectorEngine._normalize(vector);
  }

  void registerField(String name, RiemannianSemanticField field) {
    _fields[name] = field;
  }

  RiemannianSemanticField? getField(String name) {
    return _fields[name];
  }

  List<double> get currentState => List.unmodifiable(_currentState);

  void updateState(List<double> newState) {
    _currentState = newState;
  }

  Map<String, dynamic> analyzeCurrentState() {
    final results = <String, dynamic>{};
    
    for (var entry in _fields.entries) {
      results[entry.key] = entry.value.analyzeDeviation(_currentState);
    }
    
    results['overall_stability'] = _calculateOverallStability();
    results['needs_intervention'] = _needsIntervention();
    
    return results;
  }

  double _calculateOverallStability() {
    if (_fields.isEmpty) return 1.0;
    
    double totalStability = 0.0;
    for (var field in _fields.values) {
      final energy = field.calculatePotentialEnergy(_currentState);
      totalStability += 1.0 - math.min(1.0, energy);
    }
    
    return totalStability / _fields.length;
  }

  bool _needsIntervention() {
    for (var field in _fields.values) {
      final analysis = field.analyzeDeviation(_currentState);
      if (analysis['needs_correction'] == true) {
        return true;
      }
    }
    return false;
  }

  List<double> evolveState({double dt = 0.02, int iterations = 20}) {
    final field = _fields['personality'];
    if (field == null) return _currentState;
    
    _currentState = field.evolve(_currentState, dt: dt, iterations: iterations);
    return _currentState;
  }

  Map<String, dynamic> computeSemanticMetrics(List<double> queryVector) {
    final similarity = LocalVectorEngine.cosineSimilarity(_currentState, queryVector);
    final distance = LocalVectorEngine.euclideanDistance(_currentState, queryVector);
    
    final results = <String, dynamic>{
      'similarity': similarity,
      'distance': distance,
      'semantic_alignment': (similarity + 1.0) / 2.0,
    };
    
    for (var entry in _fields.entries) {
      final fieldSimilarity = LocalVectorEngine.cosineSimilarity(
        _currentState,
        entry.value.coreVector,
      );
      results['${entry.key}_alignment'] = (fieldSimilarity + 1.0) / 2.0;
    }
    
    return results;
  }
}
