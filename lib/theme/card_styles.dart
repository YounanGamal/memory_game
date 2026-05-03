import 'package:flutter/material.dart';
import 'app_colors.dart';

class CardStyles {
  static const double borderRadius = 20.0;
  
  static BoxDecoration closedDecoration = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryPink.withOpacity(0.2),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration openDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration matchedDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.primaryPink.withOpacity(0.3), width: 2),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryPink.withOpacity(0.15),
        blurRadius: 15,
        spreadRadius: 2,
      ),
    ],
  );
}
