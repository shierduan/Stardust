import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/models.dart';
import '../theme/app_theme.dart';

class CompanionAvatar extends StatefulWidget {
  final EmotionalSpectrum emotionalSpectrum;
  final BioRhythm bioRhythm;
  final String name;
  final double size;
  final VoidCallback? onTap;

  const CompanionAvatar({
    super.key,
    required this.emotionalSpectrum,
    required this.bioRhythm,
    this.name = '女娲',
    this.size = 200,
    this.onTap,
  });

  @override
  State<CompanionAvatar> createState() => _CompanionAvatarState();
}

class _CompanionAvatarState extends State<CompanionAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dominantEmotion = widget.emotionalSpectrum.dominantEmotion;
    final emotionColor = _getEmotionColor(dominantEmotion);
    final isTired = widget.bioRhythm.needsRest;
    final isHappy = widget.emotionalSpectrum.joy > 0.6;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _breathController,
        builder: (context, child) {
          final breathScale = 1.0 + (_breathController.value * 0.03);
          final pressedScale = _isPressed ? 0.95 : 1.0;
          
          return Transform.scale(
            scale: breathScale * pressedScale,
            child: _buildAvatarBody(emotionColor, isTired, isHappy),
          );
        },
      ),
    );
  }

  Widget _buildAvatarBody(Color emotionColor, bool isTired, bool isHappy) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            emotionColor.withOpacity(0.3),
            AppColors.cardDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: emotionColor.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildGlowRing(emotionColor),
          _buildFace(isTired, isHappy, emotionColor),
          _buildNameTag(),
        ],
      ),
    );
  }

  Widget _buildGlowRing(Color color) {
    return Container(
      width: widget.size * 0.85,
      height: widget.size * 0.85,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildFace(bool isTired, bool isHappy, Color emotionColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildEyes(isTired, isHappy),
        const SizedBox(height: 20),
        _buildMouth(isHappy, isTired),
      ],
    );
  }

  Widget _buildEyes(bool isTired, bool isHappy) {
    final eyeHeight = isTired ? 4.0 : (isHappy ? 16.0 : 12.0);
    final eyeColor = isHappy ? AppColors.joy : AppColors.textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _EyeWidget(
          width: 20,
          height: eyeHeight,
          color: eyeColor,
          isTired: isTired,
        ),
        SizedBox(width: widget.size * 0.15),
        _EyeWidget(
          width: 20,
          height: eyeHeight,
          color: eyeColor,
          isTired: isTired,
        ),
      ],
    );
  }

  Widget _buildMouth(bool isHappy, bool isTired) {
    if (isTired) {
      return Container(
        width: 30,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textMuted,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    if (isHappy) {
      return Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.love,
              width: 3,
            ),
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      );
    }

    return Container(
      width: 30,
      height: 12,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textPrimary,
            width: 2,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
    );
  }

  Widget _buildNameTag() {
    return Positioned(
      bottom: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surfaceDark,
            width: 1,
          ),
        ),
        child: Text(
          widget.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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

class _EyeWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final bool isTired;

  const _EyeWidget({
    required this.width,
    required this.height,
    required this.color,
    required this.isTired,
  });

  @override
  Widget build(BuildContext context) {
    if (isTired) {
      return Container(
        width: width,
        height: 2,
        color: color.withOpacity(0.5),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width / 2),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 2.seconds,
          color: color.withOpacity(0.3),
        );
  }
}
