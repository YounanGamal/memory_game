import 'package:flutter/material.dart';
import '../core/enums/game_enums.dart';
import '../theme/app_colors.dart';

class LevelCard extends StatelessWidget {
  final GameLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String label = level.name.toUpperCase();
    String details = '${level.gridSize}x${level.gridSize} Grid';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryPink : AppColors.border,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.accentPink : AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              details,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.textDark : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
