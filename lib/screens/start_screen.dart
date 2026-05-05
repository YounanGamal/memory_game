import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/game_controller.dart';
import '../controllers/progression_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/enums/game_enums.dart';
import '../theme/app_colors.dart';
import '../widgets/start/game_bottom_nav.dart';
import '../widgets/start/home_tab.dart';
import '../widgets/start/levels_tab.dart';
import '../widgets/start/stats_tab.dart';
import '../widgets/start/themes_tab.dart';
import 'game_screen.dart';
import 'power_ups_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final GameController controller = Get.put(GameController());
  final ProgressionController progression = Get.find<ProgressionController>();
  final ThemeController themeController = Get.find<ThemeController>();

  int _tabIndex = 1;
  GameMode _selectedMode = GameMode.classic;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            _titleForTab,
            style: GoogleFonts.outfit(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton.filledTonal(
              onPressed: () => Get.to(() => PowerUpsScreen(mode: _selectedMode)),
              icon: const Icon(Icons.shopping_basket_rounded),
              color: AppColors.accentPink,
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: GameNavScaffold(
          currentIndex: _tabIndex,
          onChanged: (index) => setState(() => _tabIndex = index),
          body: IndexedStack(
            index: _tabIndex,
            children: [
              HomeTab(selectedMode: _selectedMode, onContinue: _startCurrentLevel),
              LevelsTab(
                selectedMode: _selectedMode,
                onModeChanged: (mode) => setState(() => _selectedMode = mode),
                onStartLevel: _startLevel,
              ),
              const StatsTab(),
              ThemesTab(themeController: themeController),
            ],
          ),
        ),
      ),
    );
  }

  String get _titleForTab => switch (_tabIndex) {
        0 => 'Memory',
        1 => 'Levels',
        2 => 'Stats',
        _ => 'Themes',
      };

  void _startCurrentLevel() {
    final level = _selectedMode.levels.firstWhere(
      (item) => item.number == progression.highestUnlockedFor(_selectedMode),
      orElse: () => _selectedMode.levels.last,
    );
    _startLevel(level);
  }

  void _startLevel(GameLevel level) {
    if (progression.hearts.value <= 0) {
      Get.snackbar(
        'No hearts',
        'Buy a heart or restart your run to play again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    controller.startGame(level, _selectedMode);
    Get.to(() => const GameScreen());
  }
}
