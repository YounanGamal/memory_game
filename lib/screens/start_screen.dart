import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/game_controller.dart';
import '../controllers/progression_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/enums/game_enums.dart';
import '../theme/app_colors.dart';
import '../widgets/level_card.dart';
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
              onPressed: () =>
                  Get.to(() => PowerUpsScreen(mode: _selectedMode)),
              icon: const Icon(Icons.shopping_basket_rounded),
              color: AppColors.accentPink,
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _tabIndex,
            children: [
              _HomeTab(
                selectedMode: _selectedMode,
                onContinue: _startCurrentLevel,
              ),
              _LevelsTab(
                selectedMode: _selectedMode,
                onModeChanged: (mode) => setState(() => _selectedMode = mode),
                onStartLevel: _startLevel,
              ),
              const _StatsTab(),
              _ThemesTab(themeController: themeController),
            ],
          ),
        ),
        bottomNavigationBar: _GameBottomNav(
          currentIndex: _tabIndex,
          onChanged: (index) => setState(() => _tabIndex = index),
        ),
      ),
    );
  }

  String get _titleForTab {
    return switch (_tabIndex) {
      0 => 'Memory',
      1 => 'Levels',
      2 => 'Stats',
      _ => 'Themes',
    };
  }

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

class _HomeTab extends StatelessWidget {
  final GameMode selectedMode;
  final VoidCallback onContinue;

  const _HomeTab({required this.selectedMode, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final progression = Get.find<ProgressionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PlayerInfoBar(),
          const SizedBox(height: 18),
          Obx(
            () => _ProgressPanel(
              unlocked: progression.highestUnlockedFor(selectedMode),
              total: selectedMode.levels.length,
              stars: progression.totalStars.value,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
                onTap: onContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'CONTINUE',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 350.ms)
              .scale(begin: const Offset(0.96, 0.96)),
        ],
      ),
    );
  }
}

class _LevelsTab extends StatelessWidget {
  final GameMode selectedMode;
  final ValueChanged<GameMode> onModeChanged;
  final ValueChanged<GameLevel> onStartLevel;

  const _LevelsTab({
    required this.selectedMode,
    required this.onModeChanged,
    required this.onStartLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progression = Get.find<ProgressionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PlayerInfoBar(),
          const SizedBox(height: 16),
          _ModeSelector(selectedMode: selectedMode, onChanged: onModeChanged),
          const SizedBox(height: 18),
          Text(
            'Choose Level',
            style: GoogleFonts.outfit(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final levels = selectedMode.levels;
            final unlockedLevel = progression.highestUnlockedFor(selectedMode);
            final starsByLevel = Map<String, int>.from(
              progression.bestStarsByLevel,
            );

            return GridView.builder(
              itemCount: levels.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final level = levels[index];
                return LevelCard(
                  level: level,
                  isUnlocked: level.number <= unlockedLevel,
                  isCurrent: level.number == unlockedLevel,
                  stars: starsByLevel[level.name] ?? 0,
                  onTap: () => onStartLevel(level),
                );
              },
            ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.04, end: 0);
          }),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    final progression = Get.find<ProgressionController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        children: [
          const _PlayerInfoBar(),
          const SizedBox(height: 16),
          _StatTile(
            icon: Icons.emoji_events_rounded,
            label: 'Wins',
            value: '${progression.wins.value}',
          ),
          _StatTile(
            icon: Icons.star_rounded,
            label: 'Total stars',
            value: '${progression.totalStars.value}',
          ),
          _StatTile(
            icon: Icons.sports_score_rounded,
            label: 'Best score',
            value: '${progression.bestScore.value}',
          ),
          _StatTile(
            icon: Icons.favorite_rounded,
            label: 'Perfect wins',
            value: '${progression.perfectWins.value}',
          ),
          _StatTile(
            icon: Icons.grid_view_rounded,
            label: 'Classic levels',
            value:
                '${progression.highestUnlockedFor(GameMode.classic)}/${GameMode.classic.levels.length}',
          ),
          _StatTile(
            icon: Icons.timer_rounded,
            label: 'Time Attack levels',
            value:
                '${progression.highestUnlockedFor(GameMode.timeAttack)}/${GameMode.timeAttack.levels.length}',
          ),
        ],
      ),
    );
  }
}

class _ThemesTab extends StatelessWidget {
  final ThemeController themeController;

  const _ThemesTab({required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      children: [
        const _PlayerInfoBar(),
        const SizedBox(height: 16),
        Obx(
          () => _ToggleTile(
            icon: themeController.isDarkMode.value
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            label: 'Dark mode',
            value: themeController.isDarkMode.value,
            onChanged: (_) => themeController.toggleTheme(),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _CardStyleTile(
            style: CardThemeStyle.candyRush,
            colors: [AppColors.primaryPink, AppColors.primaryPurple],
            isSelected:
                themeController.cardThemeStyle.value ==
                CardThemeStyle.candyRush,
            onTap: () => themeController.setCardTheme(CardThemeStyle.candyRush),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _CardStyleTile(
            style: CardThemeStyle.sunsetGold,
            colors: const [Color(0xFFFFB23F), Color(0xFFFF5D8F)],
            isSelected:
                themeController.cardThemeStyle.value ==
                CardThemeStyle.sunsetGold,
            onTap: () =>
                themeController.setCardTheme(CardThemeStyle.sunsetGold),
          ),
        ),
      ],
    );
  }
}

class _PlayerInfoBar extends StatelessWidget {
  const _PlayerInfoBar();

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
            Expanded(child: _HeartsRow(count: progression.hearts.value)),
            if (progression.hearts.value < ProgressionController.maxHearts) ...[
              const SizedBox(width: 6),
              _BuyHeartButton(progression: progression),
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

class _BuyHeartButton extends StatelessWidget {
  final ProgressionController progression;

  const _BuyHeartButton({required this.progression});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
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
                Icon(
                  Icons.favorite_rounded,
                  color: AppColors.accentPink,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartsRow extends StatelessWidget {
  final int count;

  const _HeartsRow({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        ProgressionController.maxHearts,
        (index) => Icon(
          index < count
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: index < count ? Colors.redAccent : AppColors.textGrey,
          size: 22,
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  final int unlocked;
  final int total;
  final int stars;

  const _ProgressPanel({
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
              Icon(Icons.star_rounded, color: Colors.amber, size: 19),
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

class _ModeSelector extends StatelessWidget {
  final GameMode selectedMode;
  final ValueChanged<GameMode> onChanged;

  const _ModeSelector({required this.selectedMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: GameMode.values.map((mode) {
          final selected = selectedMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accentPink : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mode.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: selected ? Colors.white : AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPink),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.accentPink,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPink),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _CardStyleTile extends StatelessWidget {
  final CardThemeStyle style;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardStyleTile({
    required this.style,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accentPink : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            ...colors.map(
              (color) => Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.label,
                    style: GoogleFonts.outfit(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    style.description,
                    style: GoogleFonts.outfit(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.accentPink),
          ],
        ),
      ),
    );
  }
}

class _GameBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _GameBottomNav({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            icon: Icons.sports_esports_rounded,
            label: 'Levels',
            selected: currentIndex == 1,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            icon: Icons.emoji_events_rounded,
            label: 'Stats',
            selected: currentIndex == 2,
            onTap: () => onChanged(2),
          ),
          _NavItem(
            icon: Icons.palette_rounded,
            label: 'Themes',
            selected: currentIndex == 3,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentPink.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.accentPink : AppColors.textGrey,
                size: 23,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: selected ? AppColors.accentPink : AppColors.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
