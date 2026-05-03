import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({'is_dark_mode': false});
  });

  testWidgets('shows start screen after splash', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryGameApp());

    expect(find.text('MEMORY'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('Select Difficulty'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
  });
}
