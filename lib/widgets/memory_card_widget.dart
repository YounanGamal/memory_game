import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../models/card_model.dart';
import '../theme/app_colors.dart';
import '../theme/card_styles.dart';

class MemoryCardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isFlipped = card.isFlipped.value;
      final bool isMatched = card.isMatched.value;
      final bool isWrong = card.isWrong.value;

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutBack,
          tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
          builder: (context, angle, child) {
            final isBack = angle >= 90;
            Widget cardContent = isBack
                ? _buildFront(isMatched, isWrong)
                : _buildBack();

            if (isWrong) {
              cardContent = cardContent.animate()
                  .shake(hz: 8, curve: Curves.easeInOut, rotation: 0.05);
            }

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(angle * pi / 180),
              alignment: Alignment.center,
              child: cardContent,
            );
          },
        ),
      );
    });
  }

  Widget _buildFront(bool isMatched, bool isWrong) {
    Widget content = Container(
      key: const ValueKey('front'),
      decoration: isMatched 
          ? CardStyles.matchedDecoration 
          : (isWrong ? CardStyles.openDecoration.copyWith(border: Border.all(color: Colors.red.withOpacity(0.3), width: 2)) : CardStyles.openDecoration),
      child: Center(
        child: Transform(
          transform: Matrix4.identity()..rotateY(pi), // Flip back the emoji
          alignment: Alignment.center,
          child: Text(
            card.value,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );

    if (isMatched) {
      HapticFeedback.mediumImpact();
      return content.animate()
          .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 200.ms, curve: Curves.easeOut)
          .then()
          .scale(begin: const Offset(1.1,1.1), end: const Offset(1, 1), duration: 200.ms)
          .shimmer(duration: 1200.ms, color: AppColors.primaryPink.withOpacity(0.2));
    }
    
    return content;
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey('back'),
      decoration: CardStyles.closedDecoration,
      child: Stack(
        children: [
          // Subtle highlight/glossy effect
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.question_mark_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
