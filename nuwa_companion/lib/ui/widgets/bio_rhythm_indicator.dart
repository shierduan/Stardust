import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../theme/app_theme.dart';

class BioRhythmIndicator extends StatelessWidget {
  final BioRhythm bioRhythm;
  final bool compact;

  const BioRhythmIndicator({
    super.key,
    required this.bioRhythm,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact();
    }
    return _buildFull();
  }

  Widget _buildCompact() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactIndicator(
          icon: Icons.bolt,
          value: bioRhythm.energy,
          color: _getEnergyColor(bioRhythm.energy),
          label: '能量',
        ),
        const SizedBox(width: 12),
        _CompactIndicator(
          icon: Icons.people,
          value: bioRhythm.social,
          color: AppColors.primary,
          label: '社交',
        ),
        const SizedBox(width: 12),
        _CompactIndicator(
          icon: Icons.waves,
          value: 1 - bioRhythm.systemEntropy,
          color: _getEntropyColor(bioRhythm.systemEntropy),
          label: '稳定',
        ),
      ],
    );
  }

  Widget _buildFull() {
    return Column(
      children: [
        _BioRhythmBar(
          label: '精力值',
          icon: Icons.bolt,
          value: bioRhythm.energy,
          color: _getEnergyColor(bioRhythm.energy),
          status: bioRhythm.energyStatus,
        ),
        const SizedBox(height: 16),
        _BioRhythmBar(
          label: '社交渴望',
          icon: Icons.people,
          value: bioRhythm.social,
          color: AppColors.primary,
          status: bioRhythm.socialStatus,
        ),
        const SizedBox(height: 16),
        _BioRhythmBar(
          label: '系统稳定',
          icon: Icons.waves,
          value: 1 - bioRhythm.systemEntropy,
          color: _getEntropyColor(bioRhythm.systemEntropy),
          status: bioRhythm.entropyStatus,
          invertColor: true,
        ),
      ],
    );
  }

  Color _getEnergyColor(double energy) {
    if (energy > 0.6) return AppColors.energyHigh;
    if (energy > 0.3) return AppColors.energyMedium;
    return AppColors.energyLow;
  }

  Color _getEntropyColor(double entropy) {
    if (entropy < 0.3) return AppColors.energyHigh;
    if (entropy < 0.6) return AppColors.energyMedium;
    return AppColors.energyLow;
  }
}

class _CompactIndicator extends StatelessWidget {
  final IconData icon;
  final double value;
  final Color color;
  final String label;

  const _CompactIndicator({
    required this.icon,
    required this.value,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BioRhythmBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final Color color;
  final String status;
  final bool invertColor;

  const _BioRhythmBar({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.status,
    this.invertColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = invertColor ? 1 - value : value;
    final displayColor = invertColor ? color : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: displayColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              status,
              style: TextStyle(
                color: displayColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: 10,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: displayValue.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        displayColor.withOpacity(0.6),
                        displayColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
