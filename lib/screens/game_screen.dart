import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/game_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/enums/game_enums.dart';
import '../models/reward_result.dart';
import '../theme/app_colors.dart';
import '../widgets/memory_card_widget.dart';
import '../widgets/result_video_widget.dart';
import 'power_ups_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController controller = Get.find<GameController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    ever(controller.state, (state) {
      if (state == GameState.finished) {
        _showEndDialog(didWin: true);
      } else if (state == GameState.lost) {
        _showEndDialog(didWin: false);
      }
    });
  }

  void _showEndDialog({required bool didWin}) {
    if (Get.isDialogOpen == true) return;

    final isOutOfHearts = !didWin && controller.progression.hearts.value <= 0;
    final nextLevel = didWin ? controller.level.value.nextLevel : null;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResultVideoWidget(isSuccess: didWin),
              const SizedBox(height: 16),
              Text(
                didWin
                    ? 'Congratulations!'
                    : isOutOfHearts
                    ? 'Game Over'
                    : 'Time is up',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentPink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                didWin
                    ? 'You cleared the board!'
                    : isOutOfHearts
                    ? 'You ran out of hearts.'
                    : 'Try again and move faster.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              if (didWin && controller.lastReward.value != null) ...[
                _buildRewardSummary(controller.lastReward.value!),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResultRow(
                    controller.isTimeAttack ? 'Time Left' : 'Time',
                    _formatTime(
                      controller.isTimeAttack
                          ? controller.remainingSeconds.value
                          : controller.secondsElapsed.value,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow('Moves', '${controller.moves.value}'),
                  const SizedBox(height: 12),
                  _buildResultRow('Best Combo', 'x${controller.bestCombo.value}'),
                  const SizedBox(height: 12),
                  _buildResultRow(
                    'Final Score',
                    '${controller.score.value}',
                    isHighlight: true,
                  ),
                ],
              ),

              const SizedBox(height: 32),
              if (isOutOfHearts) ...[
                _buildDialogAction(
                  label: 'BUY HEART - 50',
                  icon: Icons.favorite_rounded,
                  enabled: controller.progression.canBuyHeart,
                  onTap: () async {
                    final bought = await controller.progression.buyHeart();
                    if (!bought) return;
                    Get.back();
                    controller.startGame(
                      controller.level.value,
                      controller.mode.value,
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildDialogAction(
                  label: 'RESTART FROM LEVEL 1',
                  icon: Icons.refresh_rounded,
                  onTap: () async {
                    await controller.progression.restartRun(
                      controller.mode.value,
                    );
                    Get.back();
                    controller.startGame(
                      controller.mode.value.firstLevel,
                      controller.mode.value,
                    );
                  },
                ),
              ] else
                _buildDialogAction(
                  label: didWin
                      ? nextLevel == null
                            ? 'BACK TO LEVELS'
                            : 'CONTINUE LEVEL ${nextLevel.number}'
                      : 'TRY AGAIN',
                  icon: didWin
                      ? nextLevel == null
                            ? Icons.grid_view_rounded
                            : Icons.play_arrow_rounded
                      : Icons.refresh_rounded,
                  onTap: () {
                    Get.back();
                    if (didWin) {
                      if (nextLevel == null) {
                        Get.back();
                      } else {
                        controller.startGame(nextLevel, controller.mode.value);
                      }
                    } else {
                      controller.startGame(
                        controller.level.value,
                        controller.mode.value,
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildDialogAction({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: enabled ? AppColors.primaryGradient : null,
            color: enabled ? null : AppColors.border,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textGrey)),
        SizedBox(height: 8,),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: isHighlight ? 22 : 18,
            color: isHighlight ? AppColors.accentPink : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardSummary(RewardResult reward) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentPink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on_rounded, color: AppColors.accentPink),
          const SizedBox(width: 6),
          Text(
            '+${reward.coins}',
            style: GoogleFonts.outfit(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ...List.generate(
            3,
            (index) => Icon(
              index < reward.stars
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: Colors.amber,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,

        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(controller),
              Expanded(child: _buildGrid(controller)),
              _buildPowerUpsRow(controller),
              const SizedBox(height: 16),
              _buildBottomBar(controller),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameController controller) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 380 ? 14.0 : 24.0;
    final verticalPadding = screenWidth < 380 ? 12.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCircleAction(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Get.back(),
              ),
              const SizedBox(width: 10),
              _buildCircleAction(
                icon: Icons.refresh_rounded,
                onTap: () => controller.startGame(
                  controller.level.value,
                  controller.mode.value,
                ),
              ),
              const SizedBox(width: 10),
              Obx(
                () => _buildCircleAction(
                  icon: themeController.isDarkMode.value
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  onTap: themeController.toggleTheme,
                  iconColor: AppColors.accentPink,
                ),
              ),
              const SizedBox(width: 10),
              _buildCircleAction(
                icon: Icons.shopping_basket_rounded,
                onTap: () =>
                    Get.to(() => PowerUpsScreen(mode: controller.mode.value)),
                iconColor: AppColors.accentPink,
              ),
            ],
          ),
          Flexible(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 380 ? 12 : 16,
                      vertical: screenWidth < 380 ? 7 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'SCORE: ${controller.score.value}',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth < 380 ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentPink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < controller.progression.hearts.value
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: index < controller.progression.hearts.value
                            ? Colors.redAccent
                            : AppColors.textGrey,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PROGRESS: ${controller.matchesFound.value}/${controller.level.value.pairsCount}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth < 380 ? 11 : 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth < 380 ? 9 : 11),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textDark,
          size: screenWidth < 380 ? 17 : 19,
        ),
      ),
    );
  }

  Widget _buildPowerUpsRow(GameController controller) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: PowerUpType.values
              .where((type) {
                return controller.isTimeAttack || type != PowerUpType.slowTime;
              })
              .map((type) {
                return _buildPowerUpButton(
                  type: type,
                  count: controller.progression.countFor(type),
                  cooldown: _powerUpCooldown(controller, type),
                  isEnabled: controller.canUsePowerUp(type),
                  onTap: () => controller.usePowerUp(type),
                );
              })
              .toList(),
        ),
      );
    });
  }

  Widget _buildPowerUpButton({
    required PowerUpType type,
    required int count,
    required int cooldown,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final bool isEmpty = count <= 0;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.42,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: cooldown > 0
                        ? Text(
                            '$cooldown',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _powerUpIcon(type),
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
                if (!isEmpty)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accentPink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 72,
              child: Text(
                type.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _powerUpCooldown(GameController controller, PowerUpType type) {
    return switch (type) {
      PowerUpType.reveal => controller.revealCooldown.value,
      PowerUpType.autoMatch => controller.autoMatchCooldown.value,
      PowerUpType.slowTime => controller.slowTimeCooldown.value,
      PowerUpType.highlight => controller.highlightCooldown.value,
    };
  }

  Widget _buildGrid(GameController controller) {
    return Stack(
      children: [
        Obx(() {
          final level = controller.level.value;
          final columns = level.columns;
          final rows = level.rows;
          final spacing = level.totalCards >= 36
              ? 5.0
              : level.totalCards >= 20
              ? 7.0
              : 12.0;
          final horizontalPadding = level.totalCards >= 36 ? 10.0 : 20.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth =
                    constraints.maxWidth - (spacing * (columns - 1));
                final availableHeight =
                    constraints.maxHeight - (spacing * (rows - 1));
                final cardSize = math.min(
                  availableWidth / columns,
                  availableHeight / rows,
                );
                final boardWidth =
                    (cardSize * columns) + (spacing * (columns - 1));
                final boardHeight = (cardSize * rows) + (spacing * (rows - 1));

                return Center(
                  child: SizedBox(
                    width: boardWidth,
                    height: boardHeight,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemCount: controller.cards.length,
                      itemBuilder: (context, index) {
                        return MemoryCardWidget(
                          card: controller.cards[index],
                          onTap: () =>
                              controller.onCardTap(controller.cards[index]),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }),
        Obx(() {
          if (controller.combo.value <= 1) return const SizedBox.shrink();
          return Positioned(
            top: 20,
            right: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'COMBO x${controller.combo.value} 🔥',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().shake().scale(),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar(GameController controller) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth < 380 ? 14 : 24),
      padding: EdgeInsets.symmetric(
        vertical: screenWidth < 380 ? 12 : 16,
        horizontal: screenWidth < 380 ? 24 : 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            controller.isTimeAttack ? 'LEFT' : 'TIME',
            Obx(() {
              final seconds = controller.isTimeAttack
                  ? controller.remainingSeconds.value
                  : controller.secondsElapsed.value;
              final isDanger = controller.isTimeAttack && seconds <= 10;
              final text = Text(
                _formatTime(seconds),
                style: GoogleFonts.outfit(
                  fontSize: screenWidth < 380 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: isDanger ? Colors.redAccent : AppColors.textDark,
                ),
              );

              return isDanger
                  ? text
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.08, 1.08),
                          duration: 450.ms,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.08, 1.08),
                          end: const Offset(1, 1),
                          duration: 450.ms,
                        )
                  : text;
            }),
          ),
          _divider(),
          _buildStat(
            'MOVES',
            Obx(
              () => Text(
                '${controller.moves.value}',
                style: GoogleFonts.outfit(
                  fontSize: screenWidth < 380 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          _divider(),
          _buildStat(
            'BEST',
            Obx(
              () => Text(
                'x${controller.bestCombo.value}',
                style: GoogleFonts.outfit(
                  fontSize: screenWidth < 380 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildStat(String label, Widget valueWidget) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
        valueWidget,
      ],
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

IconData _powerUpIcon(PowerUpType type) {
  return switch (type) {
    PowerUpType.reveal => Icons.visibility_rounded,
    PowerUpType.autoMatch => Icons.auto_awesome_rounded,
    PowerUpType.slowTime => Icons.slow_motion_video_rounded,
    PowerUpType.highlight => Icons.center_focus_strong_rounded,
  };
}
