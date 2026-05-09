import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AppConfigProvider extends ChangeNotifier {
  AppConfig _config = const AppConfig();

  AppConfig get config => _config;

  void updateConfig(AppConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void updateBaseUrl(String baseUrl) {
    _config = _config.copyWith(baseUrl: baseUrl);
    notifyListeners();
  }

  void updateApiKey(String apiKey) {
    _config = _config.copyWith(apiKey: apiKey);
    notifyListeners();
  }

  void updateModelName(String modelName) {
    _config = _config.copyWith(modelName: modelName);
    notifyListeners();
  }

  void updateMaxTokens(int maxTokens) {
    _config = _config.copyWith(maxTokens: maxTokens);
    notifyListeners();
  }

  void updateTemperature(double temperature) {
    _config = _config.copyWith(temperature: temperature);
    notifyListeners();
  }

  void updateEnableCache(bool enableCache) {
    _config = _config.copyWith(enableCache: enableCache);
    notifyListeners();
  }
}
