import '../../cards/models/card.dart';

class CardData {
  static List<RacingCard> getAllCards() {
    return [
      RacingCard(
        id: 'c_nitro',
        name: 'Nitro Boost',
        description: 'Short bust of extreme speed.',
        type: CardType.boost,
        rarity: CardRarity.common,
        effectValue: 1.2,
      ),
      RacingCard(
        id: 'c_turbo',
        name: 'Turbo Charger',
        description: 'Sustained speed increase.',
        type: CardType.boost,
        rarity: CardRarity.rare,
        effectValue: 1.3,
      ),
      RacingCard(
        id: 'c_sonic',
        name: 'Sonic Boom',
        description: 'Massive speed burst.',
        type: CardType.boost,
        rarity: CardRarity.epic,
        effectValue: 1.5,
      ),
      RacingCard(
        id: 'c_oil',
        name: 'Oil Slick',
        description: 'Slightly slows opponents behind.',
        type: CardType.attack,
        rarity: CardRarity.common,
        effectValue: 1.0,
      ),
      RacingCard(
        id: 'c_shield',
        name: 'Energy Shield',
        description: 'Protects from attacks.',
        type: CardType.defense,
        rarity: CardRarity.rare,
        effectValue: 1.0,
      ),
      RacingCard(
        id: 'c_magnet',
        name: 'Coin Magnet',
        description: 'Attracts nearby coins.',
        type: CardType.boost, // Utility treated as boost for now
        rarity: CardRarity.rare,
        effectValue: 1.1,
      ),
      RacingCard(
        id: 'c_warp',
        name: 'Warp Drive',
        description: 'Teleport forward.',
        type: CardType.boost,
        rarity: CardRarity.legendary,
        effectValue: 1.8,
      ),
      RacingCard(
        id: 'c_spike',
        name: 'Spike Strip',
        description: 'Damage opponent tires.',
        type: CardType.attack,
        rarity: CardRarity.epic,
        effectValue: 1.0,
      ),
      RacingCard(
        id: 'c_repair',
        name: 'Nano Repair',
        description: 'Fix vehicle damage.',
        type: CardType.defense,
        rarity: CardRarity.epic,
        effectValue: 1.0,
      ),
      RacingCard(
        id: 'c_ai',
        name: 'Auto Pilot',
        description: 'Perfect handling for a duration.',
        type: CardType.boost,
        rarity: CardRarity.legendary,
        effectValue: 1.4,
      ),
    ];
  }
}
