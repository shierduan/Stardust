import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/models.dart';
import '../theme/app_theme.dart';

class EmotionRadarChart extends StatefulWidget {
  final EmotionalSpectrum emotionalSpectrum;
  final double size;

  const EmotionRadarChart({
    super.key,
    required this.emotionalSpectrum,
    this.size = 280,
  });

  @override
  State<EmotionRadarChart> createState() => _EmotionRadarChartState();
}

class _EmotionRadarChartState extends State<EmotionRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(EmotionRadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  dataEntries: _buildDataEntries(),
                  fillColor: AppColors.primary.withOpacity(0.3 * _animation.value),
                  borderColor: AppColors.primary.withOpacity(_animation.value),
                  borderWidth: 2,
                  entryRadius: 3,
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(color: AppColors.textMuted, width: 0.5),
              titlePositionPercentageOffset: 0.15,
              titleTextStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
              getTitle: (index, angle) {
                final emotion = EmotionalSpectrum.emotions[index];
                return RadarChartTitle(
                  text: EmotionalSpectrum.emotionEmojis[emotion] ?? '',
                  angle: angle,
                );
              },
              tickCount: 4,
              ticksTextStyle: const TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
              tickBorderData: const BorderSide(
                color: AppColors.textMuted,
                width: 0.5,
              ),
              gridBorderData: const BorderSide(
                color: AppColors.surfaceDark,
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  List<RadarEntry> _buildDataEntries() {
    return EmotionalSpectrum.emotions.map((emotion) {
      final value = widget.emotionalSpectrum[emotion] * _animation.value;
      return RadarEntry(value: value);
    }).toList();
  }
}
