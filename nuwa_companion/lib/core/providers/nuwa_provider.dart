import 'package:flutter/foundation.dart';
import '../models/models.dart';

class NuwaProvider extends ChangeNotifier {
  NuwaState _state = NuwaState.initial();
  List<ChatMessage> _messages = [];
  CompanionConfig _config = const CompanionConfig();
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;

  NuwaState get state => _state;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  CompanionConfig get config => _config;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;

  EmotionalSpectrum get emotionalSpectrum => _state.emotionalSpectrum;
  BioRhythm get bioRhythm => _state.bioRhythm;
  List<MemoryItem> get recentMemories => _state.recentMemories;

  void updateState(NuwaState newState) {
    _state = newState;
    notifyListeners();
  }

  void updateEmotionalSpectrum(Map<String, double> updates) {
    final newSpectrum = _state.emotionalSpectrum.copyWith(updates: updates);
    _state = _state.copyWith(emotionalSpectrum: newSpectrum);
    notifyListeners();
  }

  void updateBioRhythm({
    double? energy,
    double? social,
    double? systemEntropy,
  }) {
    final newBioRhythm = _state.bioRhythm.copyWith(
      energy: energy,
      social: social,
      systemEntropy: systemEntropy,
      lastUpdateTimestamp: DateTime.now().millisecondsSinceEpoch / 1000,
    );
    _state = _state.copyWith(bioRhythm: newBioRhythm);
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void updateMessage(String id, ChatMessage updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setConnected(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void updateConfig(CompanionConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void addMemory(MemoryItem memory) {
    final newMemories = [..._state.recentMemories, memory];
    _state = _state.copyWith(recentMemories: newMemories);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void reset() {
    _state = NuwaState.initial();
    _messages.clear();
    _isLoading = false;
    _isConnected = false;
    _errorMessage = null;
    notifyListeners();
  }
}
