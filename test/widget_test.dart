import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/controllers/progression_controller.dart';
import 'package:memory_game/controllers/theme_controller.dart';
import 'package:memory_game/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({'is_dark_mode': false});
    final progressionController = Get.put(ProgressionController());
    final themeController = Get.put(ThemeController());
    await progressionController.load();
    await themeController.loadTheme();
  });

  testWidgets('shows start screen after splash', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryGameApp());

    expect(find.text('MEMORY'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Levels'), findsWidgets);
    expect(find.text('Choose Level'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
  });
}
