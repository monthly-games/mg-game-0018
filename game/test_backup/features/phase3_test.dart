import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/game_manager.dart';
import 'package:game/features/racing/data/vehicle_data.dart';
import 'package:game/features/cards/data/card_data.dart';
import 'package:game/features/racing/data/track_data.dart';

void main() {
  group('Phase 3 - Content Verification', () {
    test('Content Count Check', () {
      expect(VehicleData.getAllVehicles().length, greaterThanOrEqualTo(5));
      expect(CardData.getAllCards().length, greaterThanOrEqualTo(10));
      expect(TrackData.getAllTracks().length, greaterThanOrEqualTo(3));
    });

    test('Specific Content Existence', () {
      final vehicles = VehicleData.getAllVehicles();
      expect(vehicles.any((v) => v.id == 'v_drift'), true);

      final cards = CardData.getAllCards();
      expect(cards.any((c) => c.id == 'c_warp'), true);

      final tracks = TrackData.getAllTracks();
      expect(tracks.any((t) => t.id == 't_mountain'), true);
    });

    test('GameManager Initialization', () {
      final gm = GameManager();
      gm.initialize();

      // Check starter content
      expect(gm.garage.ownedVehicles.isNotEmpty, true);
      expect(gm.garage.ownedVehicles.first.id, 'v_starter');

      expect(gm.cards.ownedCards.isNotEmpty, true);
      expect(gm.cards.ownedCards.first.id, 'c_nitro');
    });
  });
}
