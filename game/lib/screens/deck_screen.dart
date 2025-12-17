import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import '../features/player/player_manager.dart';
import '../features/cards/card_data.dart';

/// Deck management screen for ability cards
class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  List<String> _selectedCardIds = [];

  @override
  void initState() {
    super.initState();
    final player = Provider.of<PlayerManager>(context, listen: false);
    _selectedCardIds = List.from(player.equippedCardIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 덱 관리'),
        backgroundColor: AppColors.primary,
        actions: [
          TextButton(
            onPressed: () => _saveDeck(context),
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Consumer<PlayerManager>(
        builder: (context, player, child) {
          return Column(
            children: [
              // Current deck (3 slots)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.panel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('현재 덱 (${_selectedCardIds.length}/3)', style: AppTextStyles.header2),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(3, (index) {
                        if (index < _selectedCardIds.length) {
                          final card = AbilityCards.getById(_selectedCardIds[index]);
                          return Expanded(
                            child: _buildDeckSlot(card, () {
                              setState(() {
                                _selectedCardIds.removeAt(index);
                              });
                            }),
                          );
                        } else {
                          return Expanded(child: _buildEmptySlot());
                        }
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Available cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('사용 가능한 카드', style: AppTextStyles.header2),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: AbilityCards.all.length,
                  itemBuilder: (context, index) {
                    final card = AbilityCards.all[index];
                    final isUnlocked = player.unlockedCards.contains(card.id);
                    final isEquipped = _selectedCardIds.contains(card.id);

                    return _buildCardTile(card, isUnlocked, isEquipped);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeckSlot(AbilityCard? card, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getCardRarityColor(card!.rarity).withOpacity(0.3),
        border: Border.all(color: _getCardRarityColor(card.rarity), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            _getCardIcon(card.type),
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            card.nameKo,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: onRemove,
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: Border.all(color: Colors.grey[600]!, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: Colors.grey[600], size: 32),
          const SizedBox(height: 8),
          Text(
            '빈 슬롯',
            style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile(AbilityCard card, bool isUnlocked, bool isEquipped) {
    return GestureDetector(
      onTap: isUnlocked && !isEquipped && _selectedCardIds.length < 3
          ? () {
              setState(() {
                _selectedCardIds.add(card.id);
              });
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isEquipped
              ? Colors.grey[700]
              : (isUnlocked
                  ? _getCardRarityColor(card.rarity).withOpacity(0.3)
                  : Colors.grey[900]),
          border: Border.all(
            color: isUnlocked ? _getCardRarityColor(card.rarity) : Colors.grey[700]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCardIcon(card.type),
                    color: isUnlocked ? Colors.white : Colors.grey[600],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.nameKo,
                    style: AppTextStyles.body.copyWith(
                      color: isUnlocked ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (isUnlocked) ...[
                    Text(
                      card.description,
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${card.baseCooldown}s',
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Icon(Icons.lock, color: Colors.white54, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      '잠김',
                      style: AppTextStyles.caption.copyWith(color: Colors.white54),
                    ),
                  ],
                ],
              ),
            ),
            if (isEquipped)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveDeck(BuildContext context) {
    final player = Provider.of<PlayerManager>(context, listen: false);
    if (player.equipCards(_selectedCardIds)) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('덱이 저장되었습니다!')),
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
}
