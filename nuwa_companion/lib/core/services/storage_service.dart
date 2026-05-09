import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _configKey = 'app_config';
  static const String _companionConfigKey = 'companion_config';
  static const String _stateKey = 'nuwa_state';
  static const String _messagesKey = 'chat_messages';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<AppConfig> loadAppConfig() async {
    await init();
    final json = _prefs?.getString(_configKey);
    if (json != null) {
      return AppConfig.fromJson(jsonDecode(json));
    }
    return const AppConfig();
  }

  Future<void> saveAppConfig(AppConfig config) async {
    await init();
    await _prefs?.setString(_configKey, jsonEncode(config.toJson()));
  }

  Future<CompanionConfig> loadCompanionConfig() async {
    await init();
    final json = _prefs?.getString(_companionConfigKey);
    if (json != null) {
      return CompanionConfig.fromJson(jsonDecode(json));
    }
    return const CompanionConfig();
  }

  Future<void> saveCompanionConfig(CompanionConfig config) async {
    await init();
    await _prefs?.setString(_companionConfigKey, jsonEncode(config.toJson()));
  }

  Future<NuwaState?> loadNuwaState() async {
    await init();
    final json = _prefs?.getString(_stateKey);
    if (json != null) {
      return NuwaState.fromJson(jsonDecode(json));
    }
    return null;
  }

  Future<void> saveNuwaState(NuwaState state) async {
    await init();
    await _prefs?.setString(_stateKey, jsonEncode(state.toJson()));
  }

  Future<List<ChatMessage>> loadMessages() async {
    await init();
    final json = _prefs?.getString(_messagesKey);
    if (json != null) {
      final list = jsonDecode(json) as List;
      return list.map((m) => ChatMessage.fromJson(m)).toList();
    }
    return [];
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    await init();
    final json = jsonEncode(messages.map((m) => m.toJson()).toList());
    await _prefs?.setString(_messagesKey, json);
  }

  Future<void> clearAll() async {
    await init();
    await _prefs?.clear();
  }
}
