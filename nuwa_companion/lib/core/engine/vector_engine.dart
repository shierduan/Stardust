import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class LocalVectorEngine {
  static const int vectorDimension = 64;
  static final math.Random _random = math.Random(42);

  static List<double> generateVector(String text) {
    final hash = _hashText(text);
    final vector = Float64List(vectorDimension);
    
    for (int i = 0; i < vectorDimension; i++) {
      vector[i] = _generateComponent(hash, i);
    }
    
    return _normalize(vector.toList());
  }

  static int _hashText(String text) {
    int hash = 5381;
    for (int i = 0; i < text.length; i++) {
      hash = ((hash << 5) + hash) + text.codeUnitAt(i);
      hash = hash & 0x7FFFFFFF;
    }
    return hash;
  }

  static double _generateComponent(int hash, int index) {
    final seed = hash ^ (index * 0x9E3779B9);
    return ((seed % 10000) / 10000.0) * 2.0 - 1.0;
  }

  static List<double> _normalize(List<double> vector) {
    double magnitude = 0.0;
    for (var v in vector) {
      magnitude += v * v;
    }
    magnitude = math.sqrt(magnitude);
    
    if (magnitude < 1e-10) {
      return vector;
    }
    
    return vector.map((v) => v / magnitude).toList();
  }

  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    normA = math.sqrt(normA);
    normB = math.sqrt(normB);
    
    if (normA < 1e-10 || normB < 1e-10) {
      return 0.0;
    }
    
    return dotProduct / (normA * normB);
  }

  static double euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }
    
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    
    return math.sqrt(sum);
  }

  static double manhattanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }
    
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      sum += (a[i] - b[i]).abs();
    }
    
    return sum;
  }

  static double angularDistance(List<double> a, List<double> b) {
    final similarity = cosineSimilarity(a, b);
    return 1.0 - (similarity + 1.0) / 2.0;
  }

  static List<double> addVectors(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }
    
    final result = Float64List(a.length);
    for (int i = 0; i < a.length; i++) {
      result[i] = a[i] + b[i];
    }
    
    return _normalize(result.toList());
  }

  static List<double> subtractVectors(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }
    
    final result = Float64List(a.length);
    for (int i = 0; i < a.length; i++) {
      result[i] = a[i] - b[i];
    }
    
    return _normalize(result.toList());
  }

  static List<double> scaleVector(List<double> vector, double scale) {
    final result = Float64List(vector.length);
    for (int i = 0; i < vector.length; i++) {
      result[i] = vector[i] * scale;
    }
    
    return _normalize(result.toList());
  }

  static List<double> interpolate(List<double> a, List<double> b, double t) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }
    
    final result = Float64List(a.length);
    for (int i = 0; i < a.length; i++) {
      result[i] = a[i] * (1.0 - t) + b[i] * t;
    }
    
    return _normalize(result.toList());
  }

  static double magnitude(List<double> vector) {
    double sum = 0.0;
    for (var v in vector) {
      sum += v * v;
    }
    return math.sqrt(sum);
  }

  static List<double> averageVectors(List<List<double>> vectors) {
    if (vectors.isEmpty) {
      return List.filled(vectorDimension, 0.0);
    }
    
    final result = Float64List(vectorDimension);
    for (var vector in vectors) {
      for (int i = 0; i < vector.length && i < vectorDimension; i++) {
        result[i] += vector[i];
      }
    }
    
    for (int i = 0; i < vectorDimension; i++) {
      result[i] /= vectors.length;
    }
    
    return _normalize(result.toList());
  }

  static List<double> weightedAverageVectors(
    List<List<double>> vectors,
    List<double> weights,
  ) {
    if (vectors.isEmpty || vectors.length != weights.length) {
      return List.filled(vectorDimension, 0.0);
    }
    
    final result = Float64List(vectorDimension);
    double totalWeight = 0.0;
    
    for (int j = 0; j < vectors.length; j++) {
      for (int i = 0; i < vectors[j].length && i < vectorDimension; i++) {
        result[i] += vectors[j][i] * weights[j];
      }
      totalWeight += weights[j];
    }
    
    if (totalWeight > 1e-10) {
      for (int i = 0; i < vectorDimension; i++) {
        result[i] /= totalWeight;
      }
    }
    
    return _normalize(result.toList());
  }

  static String vectorToString(List<double> vector) {
    return vector.map((v) => v.toStringAsFixed(4)).join(',');
  }

  static List<double> stringToVector(String str) {
    final parts = str.split(',');
    if (parts.length != vectorDimension) {
      return generateVector(str);
    }
    
    return parts.map((p) => double.tryParse(p) ?? 0.0).toList();
  }

  static Uint8List vectorToBytes(List<double> vector) {
    final buffer = Float64List.fromList(vector);
    return buffer.buffer.asUint8List();
  }

  static List<double> bytesToVector(Uint8List bytes) {
    final buffer = bytes.buffer.asFloat64List();
    return buffer.toList();
  }
}

class SimHash {
  static const int bits = 64;
  
  static int compute(List<(String, double)> features) {
    final v = List.filled(bits, 0.0);
    
    for (var (feature, weight) in features) {
      final hash = _hash64(feature);
      for (int i = 0; i < bits; i++) {
        final bit = (hash >> i) & 1;
        v[i] += bit == 1 ? weight : -weight;
      }
    }
    
    int result = 0;
    for (int i = 0; i < bits; i++) {
      if (v[i] > 0) {
        result |= (1 << i);
      }
    }
    
    return result;
  }

  static int _hash64(String text) {
    int h = 0x9e3779b97f4a7c15;
    for (int i = 0; i < text.length; i++) {
      h ^= text.codeUnitAt(i);
      h = (h ^ (h >> 30)) * 0xbf58476d1ce4e5b9;
      h = (h ^ (h >> 27)) * 0x94d049bb133111eb;
      h ^= h >> 31;
    }
    return h;
  }

  static int hammingDistance(int a, int b) {
    int xor = a ^ b;
    int count = 0;
    while (xor != 0) {
      count++;
      xor &= (xor - 1);
    }
    return count;
  }

  static double similarity(int a, int b) {
    return 1.0 - hammingDistance(a, b) / bits;
  }
}
