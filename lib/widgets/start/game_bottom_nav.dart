import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/theme_controller.dart';
import '../../theme/app_colors.dart';

const _labels = ['Home', 'Levels', 'Stats', 'Themes'];
const _icons = [
  Icons.home_rounded,
  Icons.sports_esports_rounded,
  Icons.bar_chart_rounded,
  Icons.palette_rounded,
];

class GameNavScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final Widget body;

  const GameNavScaffold({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: body,
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.only(bottom: 10),
        child: _GameNavBar(
          currentIndex: currentIndex,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _GameNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _GameNavBar({
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = Get.find<ThemeController>().isDarkMode.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF161722).withOpacity(0.8)
                      : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.04),
                  ),
                ),
                child: Row(
                  children: List.generate(
                    _labels.length,
                    (i) => _NavItem(
                      icon: _icons[i],
                      label: _labels[i],
                      isSelected: currentIndex == i,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onChanged(i);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentPink;
    final pillBg = isSelected
        ? accent.withOpacity(isDark ? 0.14 : 0.1)
        : Colors.transparent;
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.3);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 10 : 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? accent : inactiveColor,
                    ),
                    if (isSelected)
                      ClipRect(
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.centerLeft,
                          widthFactor: isSelected ? 1.0 : 0.0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              label,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}