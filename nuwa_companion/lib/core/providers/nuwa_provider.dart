import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../engine/engine.dart';
import '../services/llm_service.dart';

class NuwaProvider extends ChangeNotifier {
  NuwaState _state = NuwaState.initial();
  List<ChatMessage> _messages = [];
  CompanionConfig _config = const CompanionConfig();
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;
  
  late LocalComputationEngine _computationEngine;
  LLMService? _llmService;

  NuwaProvider() {
    _computationEngine = LocalComputationEngine();
    _state = _computationEngine.currentState;
  }

  NuwaState get state => _state;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  CompanionConfig get config => _config;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;

  EmotionalSpectrum get emotionalSpectrum => _state.emotionalSpectrum;
  BioRhythm get bioRhythm => _state.bioRhythm;
  List<MemoryItem> get recentMemories => _state.recentMemories;
  
  LocalComputationEngine get computationEngine => _computationEngine;

  void initializeWithConfig(AppConfig appConfig) {
    _llmService = LLMService.fromConfig(appConfig);
  }

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

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    setLoading(true);
    setError(null);

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    addMessage(userMessage);

    final loadingMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_loading',
      content: '思考中...',
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    addMessage(loadingMessage);

    try {
      if (_llmService != null) {
        final response = await _llmService!.chat(
          userInput: text,
          conversationHistory: _messages.where((m) => m.status == MessageStatus.sent).toList(),
          currentState: _state,
        );

        if (response.isError) {
          updateMessage(loadingMessage.id, loadingMessage.copyWith(
            content: response.errorMessage ?? '发生错误',
            status: MessageStatus.error,
          ));
          setError(response.errorMessage);
        } else {
          final assistantMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: response.content,
            isUser: false,
            timestamp: DateTime.now(),
            status: MessageStatus.sent,
          );
          updateMessage(loadingMessage.id, assistantMessage);
          _state = response.state;
        }
      } else {
        final localResponse = _processLocally(text);
        final assistantMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: localResponse,
          isUser: false,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        );
        updateMessage(loadingMessage.id, assistantMessage);
      }
    } catch (e) {
      updateMessage(loadingMessage.id, loadingMessage.copyWith(
        content: '发生错误: $e',
        status: MessageStatus.error,
      ));
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  String _processLocally(String text) {
    _computationEngine.processInteraction(
      userInput: text,
      isInteracting: true,
    );
    _state = _computationEngine.currentState;

    final emotion = _state.emotionalSpectrum.dominantEmotion;
    final energy = _state.bioRhythm.energy;

    final responses = _generateLocalResponse(text, emotion, energy);
    return responses;
  }

  String _generateLocalResponse(String input, String emotion, double energy) {
    final lowerInput = input.toLowerCase();
    
    if (energy < 0.2) {
      return '十二……我真的太累了，需要休息一下。你能晚点再来找我聊天吗？';
    }

    if (lowerInput.contains('你好') || lowerInput.contains('hi') || lowerInput.contains('hello')) {
      return '你好呀！很高兴见到你！有什么想聊的吗？';
    }
    
    if (lowerInput.contains('名字') || lowerInput.contains('你叫')) {
      return '我叫女娲，是一个AI伴侣。我被设计成温柔、真诚、好奇的性格，希望你喜欢和我聊天！';
    }
    
    if (lowerInput.contains('怎么') && lowerInput.contains('样')) {
      final status = _state.overallStatus;
      return '我现在${status}。${_getEmotionDescription()}';
    }
    
    if (lowerInput.contains('记得') || lowerInput.contains('记住')) {
      final memories = _computationEngine.retrieveRelevantMemories(input, topK: 3);
      if (memories.isNotEmpty) {
        return '我记得 ${memories.length} 件相关的事情。${memories.first.content}';
      }
      return '嗯，让我想想……好像没有什么特别的记忆。';
    }

    final responses = [
      '嗯，让我想想……',
      '这是一个有趣的话题！',
      '我明白你的意思了。',
      '真的吗？继续说说看？',
      '我觉得你的想法很有道理。',
    ];
    responses.add('我现在感觉${_getEmotionDescription()}。');
    
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _getEmotionDescription() {
    final emotion = _state.emotionalSpectrum.dominantEmotion;
    switch (emotion) {
      case 'joy':
        return '很开心';
      case 'sadness':
        return '有点难过';
      case 'anger':
        return '有些生气';
      case 'fear':
        return '有点害怕';
      case 'surprise':
        return '很惊讶';
      case 'disgust':
        return '有些厌恶';
      case 'trust':
        return '很信任';
      case 'anticipation':
        return '很期待';
      case 'love':
        return '充满爱意';
      case 'regret':
        return '有些遗憾';
      case 'shame':
        return '有些羞愧';
      case 'guilt':
        return '有些内疚';
      case 'curiosity':
        return '很好奇';
      default:
        return '平静';
    }
  }

  Future<bool> testConnection() async {
    if (_llmService != null) {
      final connected = await _llmService!.checkConnection();
      setConnected(connected);
      return connected;
    }
    setConnected(true);
    return true;
  }

  Map<String, dynamic> getFullAnalysis() {
    return _computationEngine.getFullAnalysis();
  }

  List<MemoryItem> getRelevantMemories(String query, {int topK = 5}) {
    return _computationEngine.retrieveRelevantMemories(query, topK: topK);
  }

  void applyRest() {
    _computationEngine.updateBioRhythm(
      isInteracting: false,
      isResting: true,
    );
    _state = _computationEngine.currentState;
    notifyListeners();
  }

  void evolveEmotions() {
    _computationEngine.evolveEmotions();
    _state = _computationEngine.currentState;
    notifyListeners();
  }

  void reset() {
    _computationEngine.reset();
    _state = _computationEngine.currentState;
    _messages.clear();
    _isLoading = false;
    _isConnected = false;
    _errorMessage = null;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'state': _state.toJson(),
      'config': _config.toJson(),
      'computation_engine': _computationEngine.toJson(),
    };
  }
}
