import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const CartoonRacingApp());
}

class CartoonRacingApp extends StatelessWidget {
  const CartoonRacingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartoon Racing RPG',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}
