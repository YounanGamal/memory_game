import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class ProgressPanel extends StatelessWidget {
  final int unlocked;
  final int total;
  final int stars;

  const ProgressPanel({
    super.key,
    required this.unlocked,
    required this.total,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (unlocked / total).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: GoogleFonts.outfit(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPink),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Level $unlocked of $total',
                style: GoogleFonts.outfit(color: AppColors.textGrey),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 19),
              Text(
                '$stars',
                style: GoogleFonts.outfit(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
