import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/progression_controller.dart';
import '../../theme/app_colors.dart';

class PlayerInfoBar extends StatelessWidget {
  const PlayerInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    final progression = Get.find<ProgressionController>();

    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(child: HeartsRow(count: progression.hearts.value)),
            if (progression.hearts.value < ProgressionController.maxHearts) ...[
              const SizedBox(width: 6),
              BuyHeartButton(progression: progression),
            ],
            const SizedBox(width: 10),
            Icon(Icons.monetization_on_rounded, color: AppColors.accentPink),
            const SizedBox(width: 4),
            Text(
              '${progression.coins.value}',
              style: GoogleFonts.outfit(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuyHeartButton extends StatelessWidget {
  final ProgressionController progression;

  const BuyHeartButton({super.key, required this.progression});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Tooltip(
        message: 'Buy heart for ${ProgressionController.heartCost} coins',
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: progression.canBuyHeart
              ? () async {
                  final bought = await progression.buyHeart();
                  Get.snackbar(
                    bought ? 'Heart added' : 'Not enough coins',
                    bought
                        ? 'You bought 1 heart.'
                        : 'You need ${ProgressionController.heartCost} coins.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: progression.canBuyHeart ? 1 : 0.45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.accentPink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.accentPink.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.accentPink, size: 15),
                  Icon(Icons.favorite_rounded, color: AppColors.accentPink, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeartsRow extends StatelessWidget {
  final int count;

  const HeartsRow({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        ProgressionController.maxHearts,
        (index) => Icon(
          index < count ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: index < count ? Colors.redAccent : AppColors.textGrey,
          size: 22,
        ),
      ),
    );
  }
}
