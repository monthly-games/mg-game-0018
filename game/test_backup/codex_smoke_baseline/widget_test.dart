import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('Racing app launches', (tester) async {
    await tester.pumpWidget(const CartoonRacingApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Fuel: 10/10'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
