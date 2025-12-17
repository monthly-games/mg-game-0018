import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';

import '../features/player/player_manager.dart';
import '../features/cards/card_data.dart';
import 'dart:math';

/// Shop screen for purchasing items
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상점'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<PlayerManager>(
        builder: (context, player, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Currency display
                _buildCurrencyPanel(player),

                const SizedBox(height: 24),

                // Fuel section
                Text('연료', style: AppTextStyles.header1),
                const SizedBox(height: 12),
                _buildFuelShop(context, player),

                const SizedBox(height: 24),

                // Card packs section
                Text('카드 팩', style: AppTextStyles.header1),
                const SizedBox(height: 12),
                _buildCardPackShop(context, player),

                const SizedBox(height: 24),

                // Premium currency exchange
                Text('프리미엄', style: AppTextStyles.header1),
                const SizedBox(height: 12),
                _buildPremiumShop(context, player),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyPanel(PlayerManager player) {
    return Card(
      color: AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCurrencyDisplay(Icons.monetization_on, '코인', player.coins, Colors.yellow),
            _buildCurrencyDisplay(Icons.diamond, '다이아몬드', player.diamonds, Colors.cyan),
            _buildCurrencyDisplay(Icons.local_gas_station, '연료', player.fuel, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDisplay(IconData icon, String label, int amount, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text('$amount', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFuelShop(BuildContext context, PlayerManager player) {
    final fuelOffers = [
      {'fuel': 10, 'coins': 100},
      {'fuel': 30, 'coins': 250},
      {'fuel': 50, 'coins': 400},
      {'fuel': 100, 'coins': 700},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: fuelOffers.map((offer) {
        return _buildShopItem(
          context: context,
          title: '${offer['fuel']} 연료',
          description: '연료 ${offer['fuel']} 충전',
          icon: Icons.local_gas_station,
          iconColor: Colors.orange,
          price: offer['coins']!,
          currency: '코인',
          currencyIcon: Icons.monetization_on,
          onPurchase: () => _purchaseFuel(context, player, offer['fuel']!, offer['coins']!),
        );
      }).toList(),
    );
  }

  Widget _buildCardPackShop(BuildContext context, PlayerManager player) {
    final packOffers = [
      {
        'name': '기본 팩',
        'description': '커먼 카드 1장 보장',
        'coins': 200,
        'rarity': CardRarity.common,
      },
      {
        'name': '실버 팩',
        'description': '레어 카드 1장 보장',
        'coins': 500,
        'rarity': CardRarity.rare,
      },
      {
        'name': '골드 팩',
        'description': '에픽 카드 1장 보장',
        'coins': 1200,
        'rarity': CardRarity.epic,
      },
      {
        'name': '프리미엄 팩',
        'description': '레전더리 카드 보장',
        'diamonds': 50,
        'rarity': CardRarity.legendary,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: packOffers.map((pack) {
        final useDiamonds = pack.containsKey('diamonds');
        return _buildShopItem(
          context: context,
          title: pack['name'] as String,
          description: pack['description'] as String,
          icon: Icons.style,
          iconColor: _getCardRarityColor(pack['rarity'] as CardRarity),
          price: useDiamonds ? pack['diamonds'] as int : pack['coins'] as int,
          currency: useDiamonds ? '다이아몬드' : '코인',
          currencyIcon: useDiamonds ? Icons.diamond : Icons.monetization_on,
          onPurchase: () => _purchaseCardPack(
            context,
            player,
            pack['rarity'] as CardRarity,
            useDiamonds,
            useDiamonds ? pack['diamonds'] as int : pack['coins'] as int,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPremiumShop(BuildContext context, PlayerManager player) {
    final premiumOffers = [
      {'diamonds': 10, 'coins': 500},
      {'diamonds': 25, 'coins': 1100},
      {'diamonds': 50, 'coins': 2000},
      {'diamonds': 100, 'coins': 3500},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: premiumOffers.map((offer) {
        return _buildShopItem(
          context: context,
          title: '${offer['diamonds']} 다이아몬드',
          description: '프리미엄 재화',
          icon: Icons.diamond,
          iconColor: Colors.cyan,
          price: offer['coins']!,
          currency: '코인',
          currencyIcon: Icons.monetization_on,
          onPurchase: () => _purchaseDiamonds(context, player, offer['diamonds']!, offer['coins']!),
        );
      }).toList(),
    );
  }

  Widget _buildShopItem({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required int price,
    required String currency,
    required IconData currencyIcon,
    required VoidCallback onPurchase,
  }) {
    return SizedBox(
      width: 160,
      child: Card(
        color: AppColors.panel,
        child: InkWell(
          onTap: onPurchase,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 48),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.header2.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(currencyIcon, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '$price',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _purchaseFuel(BuildContext context, PlayerManager player, int fuelAmount, int cost) {
    if (player.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코인이 부족합니다!')),
      );
      return;
    }

    if (player.fuel >= 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연료가 가득 찼습니다!')),
      );
      return;
    }

    if (player.spendCoins(cost)) {
      player.addFuel(fuelAmount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('연료 $fuelAmount 충전 완료!')),
      );
    }
  }

  void _purchaseCardPack(
    BuildContext context,
    PlayerManager player,
    CardRarity guaranteedRarity,
    bool useDiamonds,
    int cost,
  ) {
    final hasEnough = useDiamonds
        ? player.diamonds >= cost
        : player.coins >= cost;

    if (!hasEnough) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${useDiamonds ? '다이아몬드' : '코인'}가 부족합니다!')),
      );
      return;
    }

    // Spend currency
    final success = useDiamonds
        ? player.spendDiamonds(cost)
        : player.spendCoins(cost);

    if (!success) return;

    // Determine which card to unlock based on rarity
    final availableCards = AbilityCards.all
        .where((card) =>
            card.rarity == guaranteedRarity &&
            !player.unlockedCards.contains(card.id))
        .toList();

    if (availableCards.isEmpty) {
      // All cards of this rarity already unlocked, refund and notify
      if (useDiamonds) {
        player.addDiamonds(cost);
      } else {
        player.addCoins(cost);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 모든 카드를 보유하고 있습니다!')),
      );
      return;
    }

    // Randomly select one card to unlock
    final random = Random();
    final unlockedCard = availableCards[random.nextInt(availableCards.length)];
    player.unlockCard(unlockedCard.id);

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 획득!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCardIcon(unlockedCard.type),
              size: 64,
              color: _getCardRarityColor(unlockedCard.rarity),
            ),
            const SizedBox(height: 16),
            Text(
              unlockedCard.nameKo,
              style: AppTextStyles.header2,
            ),
            const SizedBox(height: 8),
            Text(
              unlockedCard.description,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getRarityText(unlockedCard.rarity),
              style: TextStyle(
                color: _getCardRarityColor(unlockedCard.rarity),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _purchaseDiamonds(BuildContext context, PlayerManager player, int diamonds, int cost) {
    if (player.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코인이 부족합니다!')),
      );
      return;
    }

    if (player.spendCoins(cost)) {
      player.addDiamonds(diamonds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다이아몬드 $diamonds 구매 완료!')),
      );
    }
  }

  Color _getCardRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return Colors.grey;
      case CardRarity.rare:
        return Colors.blue;
      case CardRarity.epic:
        return Colors.purple;
      case CardRarity.legendary:
        return Colors.amber;
    }
  }

  IconData _getCardIcon(CardType type) {
    switch (type) {
      case CardType.boost:
        return Icons.flash_on;
      case CardType.shield:
        return Icons.shield;
      case CardType.missile:
        return Icons.rocket_launch;
      case CardType.slowdown:
        return Icons.slow_motion_video;
      case CardType.magnet:
        return Icons.attractions;
      case CardType.jump:
        return Icons.arrow_upward;
      case CardType.repair:
        return Icons.healing;
    }
  }

  String _getRarityText(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return '커먼';
      case CardRarity.rare:
        return '레어';
      case CardRarity.epic:
        return '에픽';
      case CardRarity.legendary:
        return '레전더리';
    }
  }
}
