import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';
import 'package:game/screens/main_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows MainScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const CartoonRacingApp());
    await tester.pump(); // Start Future
    await tester.pump(
      const Duration(milliseconds: 100),
    ); // Wait for generic async
    await tester.pump(); // Rebuild

    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.text('Cartoon Racing RPG'), findsOneWidget);
    expect(find.text('Garage (Upgrades)'), findsOneWidget);
    expect(find.text('Race Track'), findsOneWidget);
  });

  testWidgets('Navigation logic', (WidgetTester tester) async {
    await tester.pumpWidget(const CartoonRacingApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // Tap Garage
    await tester.tap(find.text('Garage (Upgrades)'));
    await tester.pumpAndSettle();

    expect(find.text('Garage'), findsOneWidget);
    // Find Starter Kart
    expect(find.text('Starter Kart'), findsOneWidget);

    // Go Back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap Race
    await tester.tap(find.text('Race Track'));
    await tester.pumpAndSettle();

    expect(find.text('Race Simulation'), findsOneWidget);
    expect(find.text('START RACE'), findsOneWidget);
  });
}
