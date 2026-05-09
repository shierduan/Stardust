import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../theme/app_theme.dart';

class EmotionBarList extends StatelessWidget {
  final EmotionalSpectrum emotionalSpectrum;
  final int maxDisplay;

  const EmotionBarList({
    super.key,
    required this.emotionalSpectrum,
    this.maxDisplay = 6,
  });

  @override
  Widget build(BuildContext context) {
    final sortedEmotions = emotionalSpectrum.sortedByIntensity;
    final displayEmotions = sortedEmotions.take(maxDisplay).toList();

    return Column(
      children: displayEmotions.map((entry) {
        return _EmotionBar(
          emotion: entry.key,
          value: entry.value,
          label: EmotionalSpectrum.emotionLabels[entry.key] ?? entry.key,
          emoji: EmotionalSpectrum.emotionEmojis[entry.key] ?? '',
          color: _getEmotionColor(entry.key),
        );
      }).toList(),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'joy':
        return AppColors.joy;
      case 'sadness':
        return AppColors.sadness;
      case 'anger':
        return AppColors.anger;
      case 'fear':
        return AppColors.fear;
      case 'surprise':
        return AppColors.surprise;
      case 'disgust':
        return AppColors.disgust;
      case 'trust':
        return AppColors.trust;
      case 'anticipation':
        return AppColors.anticipation;
      case 'love':
        return AppColors.love;
      case 'regret':
        return AppColors.regret;
      case 'shame':
        return AppColors.shame;
      case 'guilt':
        return AppColors.guilt;
      case 'curiosity':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}

class _EmotionBar extends StatelessWidget {
  final String emotion;
  final double value;
  final String label;
  final String emoji;
  final Color color;

  const _EmotionBar({
    required this.emotion,
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: double.infinity,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.7),
                            color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
