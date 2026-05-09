import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/providers.dart';
import '../../core/services/services.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  bool _isTestingConnection = false;
  String? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final appConfig = await _storageService.loadAppConfig();
    if (mounted) {
      context.read<AppConfigProvider>().updateConfig(appConfig);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        title: const Text('设置'),
      ),
      body: Consumer<AppConfigProvider>(
        builder: (context, provider, _) {
          final config = provider.config;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: '服务器配置',
                  children: [
                    _buildTextField(
                      label: '服务器地址',
                      value: config.baseUrl,
                      hint: 'http://127.0.0.1:1234/v1',
                      onChanged: provider.updateBaseUrl,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'API Key',
                      value: config.apiKey,
                      hint: 'lm-studio',
                      onChanged: provider.updateApiKey,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: '模型名称',
                      value: config.modelName,
                      hint: 'local-model',
                      onChanged: provider.updateModelName,
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: 'Temperature',
                      value: config.temperature,
                      min: 0.0,
                      max: 2.0,
                      onChanged: provider.updateTemperature,
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: '最大 Token 数',
                      value: config.maxTokens.toDouble(),
                      min: 128,
                      max: 4096,
                      divisions: 31,
                      onChanged: (v) => provider.updateMaxTokens(v.toInt()),
                    ),
                    const SizedBox(height: 16),
                    _buildConnectionTest(config.baseUrl, config.apiKey),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: '伴侣设置',
                  children: [
                    Consumer<NuwaProvider>(
                      builder: (context, nuwaProvider, _) {
                        return _buildTextField(
                          label: '伴侣名称',
                          value: nuwaProvider.config.name,
                          hint: '女娲',
                          onChanged: (value) {
                            nuwaProvider.updateConfig(
                              nuwaProvider.config.copyWith(name: value),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<NuwaProvider>(
                      builder: (context, nuwaProvider, _) {
                        return _buildSwitchTile(
                          label: '显示思考气泡',
                          subtitle: '在回复中显示思考过程',
                          value: nuwaProvider.config.showThoughtBubble,
                          onChanged: (value) {
                            nuwaProvider.updateConfig(
                              nuwaProvider.config.copyWith(
                                showThoughtBubble: value,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: '关于',
                  children: [
                    _buildInfoTile(
                      icon: Icons.info_outline,
                      label: '版本',
                      value: '1.0.0',
                    ),
                    _buildInfoTile(
                      icon: Icons.code,
                      label: '框架',
                      value: 'Nuwa Framework',
                    ),
                    _buildInfoTile(
                      icon: Icons.psychology,
                      label: '核心特性',
                      value: '情感系统 · 记忆皮层 · 生物节律',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDangerZone(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          style: const TextStyle(color: AppColors.textPrimary),
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceDark,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDark,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildConnectionTest(String baseUrl, String apiKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isTestingConnection ? null : _testConnection,
                icon: _isTestingConnection
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.wifi, size: 18),
                label: Text(_isTestingConnection ? '测试中...' : '测试连接'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (_connectionStatus != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _connectionStatus == '连接成功'
                    ? Icons.check_circle
                    : Icons.error,
                size: 16,
                color: _connectionStatus == '连接成功'
                    ? AppColors.success
                    : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                _connectionStatus!,
                style: TextStyle(
                  fontSize: 13,
                  color: _connectionStatus == '连接成功'
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = null;
    });

    final provider = context.read<AppConfigProvider>();
    final apiService = ApiService.fromConfig(provider.config);
    final success = await apiService.checkConnection();

    if (mounted) {
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = success ? '连接成功' : '连接失败，请检查配置';
      });
      context.read<NuwaProvider>().setConnected(success);
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '危险区域',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error.withOpacity(0.8),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildDangerButton(
                label: '重置状态',
                subtitle: '将伴侣状态恢复到初始值',
                icon: Icons.refresh,
                onTap: _resetState,
              ),
              const Divider(color: AppColors.surfaceDark, height: 24),
              _buildDangerButton(
                label: '清除所有数据',
                subtitle: '删除所有本地存储的数据',
                icon: Icons.delete_forever,
                onTap: _clearAllData,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () => _showConfirmDialog(
        title: label,
        content: '确定要$label吗？此操作不可撤销。',
        onConfirm: onTap,
        isDestructive: isDestructive,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isDestructive ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? AppColors.error : AppColors.warning,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          content,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              '确定',
              style: TextStyle(
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetState() {
    context.read<NuwaProvider>().reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('状态已重置'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _clearAllData() async {
    await _storageService.clearAll();
    if (mounted) {
      context.read<NuwaProvider>().reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所有数据已清除'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
