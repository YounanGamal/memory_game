import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../models/card_model.dart';
import '../theme/card_styles.dart';

class MemoryCardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const MemoryCardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isFlipped = card.isFlipped.value;
      final bool isMatched = card.isMatched.value;
      final bool isWrong = card.isWrong.value;
      final bool isHighlighted = card.isHighlighted.value;

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
                : _buildBack(isHighlighted);

            if (isWrong) {
              cardContent = cardContent.animate().shake(
                hz: 8,
                curve: Curves.easeInOut,
                rotation: 0.05,
              );
            }

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(angle * pi / 180),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(1.5),
                child: cardContent,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildFront(bool isMatched, bool isWrong) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = (constraints.maxWidth * 0.52).clamp(18.0, 32.0);

        return Container(
          key: const ValueKey('front'),
          clipBehavior: Clip.antiAlias,
          decoration: isMatched
              ? CardStyles.matchedDecoration
              : (isWrong
                    ? CardStyles.openDecoration.copyWith(
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      )
                    : CardStyles.openDecoration),
          child: Center(
            child: Transform(
              transform: Matrix4.identity()..rotateY(pi), // Flip back the emoji
              alignment: Alignment.center,
              child: Text(card.value, style: TextStyle(fontSize: fontSize)),
            ),
          ),
        );
      },
    );

    if (isMatched) {
      HapticFeedback.mediumImpact();
      return content
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 200.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1, 1),
            duration: 200.ms,
          )
          .shimmer(
            duration: 1200.ms,
            color: CardStyles.accentColor.withValues(alpha: 0.2),
          );
    }

    return content;
  }

  Widget _buildBack(bool isHighlighted) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = (constraints.maxWidth * 0.42).clamp(16.0, 30.0);
        final glossSize = (constraints.maxWidth * 1.45).clamp(44.0, 80.0);

        final baseDecoration = CardStyles.closedDecoration;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          key: const ValueKey('back'),
          clipBehavior: Clip.antiAlias,
          decoration: isHighlighted
              ? baseDecoration.copyWith(
                  border: Border.all(color: Colors.amberAccent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                )
              : baseDecoration,
          child: Stack(
            children: [
              // Subtle highlight/glossy effect
              Positioned(
                top: -glossSize * 0.25,
                left: -glossSize * 0.25,
                child: Container(
                  width: glossSize,
                  height: glossSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: iconSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
