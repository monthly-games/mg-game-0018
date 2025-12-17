// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:game/main.dart';
import 'package:game/game/breaker_game.dart';

void main() {
  testWidgets('BreakerGame renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BreakerApp());

    // Verify that the GameWidget is present.
    expect(find.byType(GameWidget<BreakerGame>), findsOneWidget);
  });
}
