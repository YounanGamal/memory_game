import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/theme_controller.dart';
import '../theme/app_colors.dart';
import 'start_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.off(
      () => const StartScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColors.splashGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Icon
              Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: themeController.isDarkMode.value ? 0.1 : 0.2,
                      ),
                      shape: BoxShape.circle,
                      border: themeController.isDarkMode.value
                          ? Border.all(color: AppColors.border)
                          : null,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 200.ms)
                  .shimmer(delay: 800.ms, duration: 1500.ms),

              const SizedBox(height: 24),

              // App Name
              Text(
                'MEMORY',
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                themeController.isDarkMode.value
                    ? 'Dark Mode Ready'
                    : 'Challenge Your Mind',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
