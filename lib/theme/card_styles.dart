import 'package:flutter/material.dart';
import 'app_colors.dart';

class CardStyles {
  static const double borderRadius = 20.0;

  static BoxDecoration get closedDecoration => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryPink.withValues(alpha: 0.2),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get openDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get matchedDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: AppColors.primaryPink.withValues(alpha: 0.3),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryPink.withValues(alpha: 0.15),
        blurRadius: 15,
        spreadRadius: 2,
      ),
    ],
  );
}
