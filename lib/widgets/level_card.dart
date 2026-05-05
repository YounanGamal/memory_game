import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/enums/game_enums.dart';
import '../theme/app_colors.dart';

class LevelCard extends StatelessWidget {
  final GameLevel level;
  final bool isUnlocked;
  final bool isCurrent;
  final int stars;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.isUnlocked,
    required this.isCurrent,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isUnlocked
        ? LinearGradient(
            colors: isCurrent
                ? [const Color(0xFFFFB23F), AppColors.primaryPink]
                : [AppColors.primaryPink, AppColors.primaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              AppColors.textGrey.withValues(alpha: 0.35),
              AppColors.textGrey.withValues(alpha: 0.18),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
          onTap: isUnlocked ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0),
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color:
                            (isCurrent
                                    ? AppColors.primaryPink
                                    : AppColors.primaryPurple)
                                .withValues(alpha: isCurrent ? 0.34 : 0.18),
                        blurRadius: isCurrent ? 18 : 10,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : [],
            ),
            child: isUnlocked
                ? _UnlockedContent(level: level, stars: stars)
                : const Icon(Icons.lock_rounded, color: Colors.white, size: 34),
          ),
        )
        .animate(target: isUnlocked ? 1 : 0)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: 180.ms,
        )
        .then()
        .shimmer(
          duration: isCurrent ? 1300.ms : 1.ms,
          color: Colors.white.withValues(alpha: isCurrent ? 0.24 : 0),
        );
  }
}

class _UnlockedContent extends StatelessWidget {
  final GameLevel level;
  final int stars;

  const _UnlockedContent({required this.level, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Level ${level.number}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            level.gridLabel,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Icon(
              index < stars ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xFFFFD75E),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
