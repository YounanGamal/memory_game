import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/progression_controller.dart';
import '../core/enums/game_enums.dart';
import '../theme/app_colors.dart';

class PowerUpsScreen extends StatelessWidget {
  const PowerUpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progression = Get.find<ProgressionController>();

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: Get.back,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Power-Ups',
                        style: GoogleFonts.outfit(
                          color: AppColors.textDark,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _WalletPill(coins: progression.coins.value),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Buy helpers with coins and use them during the game.',
                  style: GoogleFonts.outfit(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView.separated(
                    itemCount: PowerUpType.values.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final type = PowerUpType.values[index];
                      return _PowerUpCard(
                        type: type,
                        owned: progression.countFor(type),
                        canBuy: progression.canBuy(type),
                        onBuy: () => progression.buyPowerUp(type),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PowerUpCard extends StatelessWidget {
  final PowerUpType type;
  final int owned;
  final bool canBuy;
  final VoidCallback onBuy;

  const _PowerUpCard({
    required this.type,
    required this.owned,
    required this.canBuy,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accentPink.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(_powerUpIcon(type), color: AppColors.accentPink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: GoogleFonts.outfit(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _descriptionFor(type),
                  style: GoogleFonts.outfit(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Owned: $owned',
                  style: GoogleFonts.outfit(
                    color: AppColors.accentPink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: canBuy ? onBuy : null,
            icon: const Icon(Icons.shopping_basket_rounded, size: 17),
            label: Text('${type.cost}'),
          ),
        ],
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  final int coins;

  const _WalletPill({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on_rounded,
            color: AppColors.accentPink,
            size: 18,
          ),
          const SizedBox(width: 5),
          Text(
            '$coins',
            style: GoogleFonts.outfit(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textDark, size: 18),
      ),
    );
  }
}

String _descriptionFor(PowerUpType type) {
  return switch (type) {
    PowerUpType.reveal => 'Flip all unmatched cards for a short moment.',
    PowerUpType.autoMatch => 'Match one available pair instantly.',
    PowerUpType.slowTime => 'Slow the countdown in time attack mode.',
    PowerUpType.highlight => 'Glow one hidden pair for two seconds.',
  };
}

IconData _powerUpIcon(PowerUpType type) {
  return switch (type) {
    PowerUpType.reveal => Icons.visibility_rounded,
    PowerUpType.autoMatch => Icons.auto_awesome_rounded,
    PowerUpType.slowTime => Icons.slow_motion_video_rounded,
    PowerUpType.highlight => Icons.center_focus_strong_rounded,
  };
}
