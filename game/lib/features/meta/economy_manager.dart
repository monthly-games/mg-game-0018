import 'package:flutter/foundation.dart';

class EconomyManager extends ChangeNotifier {
  int _coins = 0;
  int _gems = 0;

  int get coins => _coins;
  int get gems => _gems;

  void addCoins(int amount) {
    if (amount < 0) return;
    _coins += amount;
    notifyListeners();
  }

  void addGems(int amount) {
    if (amount < 0) return;
    _gems += amount;
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (amount < 0 || _coins < amount) return false;
    _coins -= amount;
    notifyListeners();
    return true;
  }

  bool spendGems(int amount) {
    if (amount < 0 || _gems < amount) return false;
    _gems -= amount;
    notifyListeners();
    return true;
  }

  // Persistence (Simplified for now)
  Map<String, dynamic> toJson() {
    return {'coins': _coins, 'gems': _gems};
  }

  void loadFromJson(Map<String, dynamic> json) {
    _coins = json['coins'] ?? 0;
    _gems = json['gems'] ?? 0;
    notifyListeners();
  }
}
