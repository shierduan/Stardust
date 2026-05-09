import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class EmotionScreen extends StatelessWidget {
  const EmotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        title: const Text('情感状态'),
      ),
      body: Consumer<NuwaProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCard(provider),
                const SizedBox(height: 24),
                _buildRadarSection(provider),
                const SizedBox(height: 24),
                _buildEmotionList(provider),
                const SizedBox(height: 24),
                _buildBioRhythmSection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(NuwaProvider provider) {
    final state = provider.state;
    final dominantEmotion = state.emotionalSpectrum.dominantEmotion;
    final dominantLabel = _getEmotionLabel(dominantEmotion);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.secondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildEmotionIcon(dominantEmotion),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前主导情绪',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dominantLabel,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: '情绪强度',
                value: '${(state.emotionalSpectrum.averageIntensity * 100).toInt()}%',
                color: AppColors.primary,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppColors.surfaceDark,
              ),
              _StatItem(
                label: '情绪效价',
                value: _getValenceLabel(state.emotionalSpectrum.emotionalValence),
                color: state.emotionalSpectrum.emotionalValence > 0
                    ? AppColors.success
                    : AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadarSection(NuwaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.radar, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                '情感雷达图',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: EmotionRadarChart(
              emotionalSpectrum: provider.emotionalSpectrum,
              size: 280,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionList(NuwaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.secondary, size: 20),
              SizedBox(width: 8),
              Text(
                '情绪分布',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          EmotionBarList(
            emotionalSpectrum: provider.emotionalSpectrum,
            maxDisplay: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildBioRhythmSection(NuwaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: AppColors.love, size: 20),
              SizedBox(width: 8),
              Text(
                '生物节律',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BioRhythmIndicator(
            bioRhythm: provider.bioRhythm,
            compact: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionIcon(String emotion) {
    const icons = {
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
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          icons[emotion] ?? '😊',
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  String _getEmotionLabel(String emotion) {
    const labels = {
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
    return labels[emotion] ?? emotion;
  }

  String _getValenceLabel(double valence) {
    if (valence > 0.3) return '积极';
    if (valence < -0.3) return '消极';
    return '中性';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
