import 'package:flutter/foundation.dart';
import '../cards/models/card.dart';
import 'economy_manager.dart';
import 'upgrade_config.dart';
import '../cards/data/card_data.dart';

class CardManager extends ChangeNotifier {
  final EconomyManager _economy;
  final List<RacingCard> _ownedCards = [];
  final List<String> _deckCardIds = [];

  CardManager(this._economy);

  List<RacingCard> get ownedCards => List.unmodifiable(_ownedCards);
  List<RacingCard> get deck =>
      _ownedCards.where((c) => _deckCardIds.contains(c.id)).toList();

  void addCard(RacingCard card) {
    if (!_ownedCards.any((c) => c.id == card.id)) {
      _ownedCards.add(card);
      // Auto-equip if deck has space (limit 3)
      if (_deckCardIds.length < 3) {
        _deckCardIds.add(card.id);
      }
      notifyListeners();
    }
  }

  bool equipCard(String cardId) {
    if (!_ownedCards.any((c) => c.id == cardId)) return false;
    if (_deckCardIds.contains(cardId)) return true; // Already equipped

    if (_deckCardIds.length >= 3) {
      // Deck full
      return false;
    }

    _deckCardIds.add(cardId);
    notifyListeners();
    return true;
  }

  void unequipCard(String cardId) {
    if (_deckCardIds.remove(cardId)) {
      notifyListeners();
    }
  }

  bool upgradeCard(String cardId) {
    final int index = _ownedCards.indexWhere((c) => c.id == cardId);
    if (index == -1) return false;

    final card = _ownedCards[index];
    final cost = UpgradeConfig.getUpgradeCost(card.level) * 2;

    if (_economy.spendCoins(cost)) {
      final newCard = RacingCard(
        id: card.id,
        name: card.name,
        description: card.description,
        type: card.type,
        rarity: card.rarity,
        effectValue: card.effectValue,
        level: card.level + 1,
      );

      _ownedCards[index] = newCard;
      notifyListeners();
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'ownedCards': _ownedCards.map((c) => c.toJson()).toList(),
      'deckIds': _deckCardIds,
    };
  }

  void loadFromJson(Map<String, dynamic> json) {
    _ownedCards.clear();
    final List<dynamic> cardsJson = json['ownedCards'] ?? [];

    // We need access to CardData to restore base data.
    final baseList = CardData.getAllCards();

    for (var cJson in cardsJson) {
      final id = cJson['id'];
      try {
        final base = baseList.firstWhere((b) => b.id == id);
        final restored = RacingCard.fromJson(cJson, base);
        _ownedCards.add(restored);
      } catch (e) {
        debugPrint('Failed to load card $id: $e');
      }
    }

    _deckCardIds.clear();
    _deckCardIds.addAll(List<String>.from(json['deckIds'] ?? []));
    notifyListeners();
  }
}
