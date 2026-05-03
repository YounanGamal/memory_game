import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/game_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/enums/game_enums.dart';
import '../theme/app_colors.dart';
import '../widgets/memory_card_widget.dart';

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
    // Listen for win state
    ever(controller.state, (state) {
      if (state == GameState.finished) {
        _showWinDialog();
      }
    });
  }

  void _showWinDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Congratulations!',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentPink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You cleared the board!',
                style: GoogleFonts.outfit(color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              _buildResultRow(
                'Time',
                _formatTime(controller.secondsElapsed.value),
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
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Get.back(); // Close dialog
                  Get.back(); // Back to start screen
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      'PLAY AGAIN',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textGrey)),
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
        children: [
          // Back Button
          Row(
            children: [
              _buildCircleAction(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Get.back(),
              ),
              const SizedBox(width: 10),
              _buildCircleAction(
                icon: Icons.refresh_rounded,
                onTap: () => controller.startGame(controller.level.value),
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
            ],
          ),

          // Progress & Score
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
                  Text(
                    'PROGRESS: ${controller.matchesFound.value}/${(controller.level.value.gridSize * controller.level.value.gridSize) ~/ 2}',
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

  Widget _buildGrid(GameController controller) {
    return Stack(
      children: [
        Obx(() {
          int gridSize = controller.level.value.gridSize;
          final spacing = gridSize >= 6 ? 6.0 : (gridSize >= 4 ? 12.0 : 16.0);
          final horizontalPadding = gridSize >= 6 ? 12.0 : 24.0;
          final childAspectRatio = gridSize >= 6 ? 0.93 : 1.0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Center(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: controller.cards.length,
                itemBuilder: (context, index) {
                  return MemoryCardWidget(
                    card: controller.cards[index],
                    onTap: () => controller.onCardTap(controller.cards[index]),
                  );
                },
              ),
            ),
          );
        }),

        // Combo Indicator
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
            'TIME',
            Obx(
              () => Text(
                _formatTime(controller.secondsElapsed.value),
                style: GoogleFonts.outfit(
                  fontSize: screenWidth < 380 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          _buildStat(
            'MOVES',
            Obx(
              () => Text(
                '${controller.moves.value}',
                style: GoogleFonts.outfit(
                  fontSize: screenWidth < 380 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          _buildStat(
            'BEST',
            Obx(
              () => Text(
                'x${controller.bestCombo.value}',
                style: GoogleFonts.outfit(
                  fontSize: screenWidth < 380 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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

  // Note: I will add the Win Dialog listener in the controller or here using ever()
}
