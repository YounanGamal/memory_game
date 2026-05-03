import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/game_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/enums/game_enums.dart';
import '../theme/app_colors.dart';
import '../widgets/level_card.dart';
import 'game_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final GameController controller = Get.put(GameController());
  final ThemeController themeController = Get.find<ThemeController>();
  GameLevel _selectedLevel = GameLevel.easy;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filledTonal(
                    onPressed: themeController.toggleTheme,
                    icon: Icon(
                      themeController.isDarkMode.value
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                    color: AppColors.accentPink,
                  ),
                ),
                const Spacer(),
                // Title
                Text(
                  'Memory',
                  style: GoogleFonts.outfit(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentPink,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),

                Text(
                  'Train your brain with fun',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppColors.textGrey,
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 12),

                Text(
                  'Match pairs fast, build combos, beat your score.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 60),

                // Level Selection
                Text(
                  'Select Difficulty',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: LevelCard(
                        level: GameLevel.easy,
                        isSelected: _selectedLevel == GameLevel.easy,
                        onTap: () =>
                            setState(() => _selectedLevel = GameLevel.easy),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LevelCard(
                        level: GameLevel.medium,
                        isSelected: _selectedLevel == GameLevel.medium,
                        onTap: () =>
                            setState(() => _selectedLevel = GameLevel.medium),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LevelCard(
                        level: GameLevel.hard,
                        isSelected: _selectedLevel == GameLevel.hard,
                        onTap: () =>
                            setState(() => _selectedLevel = GameLevel.hard),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),

                const Spacer(),
                // Start Button
                GestureDetector(
                      onTap: () async {
                        controller.startGame(_selectedLevel);
                        Get.to(() => const GameScreen());
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPink.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'START GAME',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
