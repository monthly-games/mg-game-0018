import 'dart:ui';
import 'package:flame/components.dart';

/// Track difficulty and theme
enum TrackType {
  city,      // 도시
  desert,    // 사막
  snow,      // 설원
  jungle,    // 정글
  volcanic,  // 화산
  space,     // 우주
  underwater, // 해저
  rainbow,   // 무지개 로드
}

/// Checkpoint for lap tracking
class Checkpoint {
  final Vector2 position;
  final double width;
  final double height;
  final int index;

  const Checkpoint({
    required this.position,
    required this.width,
    required this.height,
    required this.index,
  });

  bool contains(Vector2 point) {
    return point.x >= position.x &&
        point.x <= position.x + width &&
        point.y >= position.y &&
        point.y <= position.y + height;
  }
}

/// Track definition
class Track {
  final String id;
  final String nameKo;
  final TrackType type;
  final int requiredLeague; // 1-5
  final int unlockCost;

  // Track layout
  final Vector2 size;
  final List<Vector2> centerLine; // Track center path
  final double trackWidth;
  final List<Checkpoint> checkpoints;
  final Vector2 startPosition;
  final double startAngle; // Radians

  // Visual
  final Color roadColor;
  final Color borderColor;
  final Color backgroundColor;

  const Track({
    required this.id,
    required this.nameKo,
    required this.type,
    required this.requiredLeague,
    required this.unlockCost,
    required this.size,
    required this.centerLine,
    required this.trackWidth,
    required this.checkpoints,
    required this.startPosition,
    required this.startAngle,
    required this.roadColor,
    required this.borderColor,
    required this.backgroundColor,
  });
}

/// All available tracks
class Tracks {
  static final city1 = Track(
    id: 'city_1',
    nameKo: '네온 시티 서킷',
    type: TrackType.city,
    requiredLeague: 1, // Bronze
    unlockCost: 0, // Free
    size: Vector2(1200, 800),
    centerLine: [
      Vector2(200, 400),
      Vector2(400, 200),
      Vector2(800, 200),
      Vector2(1000, 400),
      Vector2(800, 600),
      Vector2(400, 600),
      Vector2(200, 400),
    ],
    trackWidth: 120,
    checkpoints: [
      Checkpoint(position: Vector2(350, 150), width: 100, height: 20, index: 0),
      Checkpoint(position: Vector2(950, 350), width: 20, height: 100, index: 1),
      Checkpoint(position: Vector2(750, 620), width: 100, height: 20, index: 2),
      Checkpoint(position: Vector2(150, 350), width: 20, height: 100, index: 3),
    ],
    startPosition: Vector2(200, 400),
    startAngle: 0,
    roadColor: Color(0xFF333333),
    borderColor: Color(0xFFFFFF00),
    backgroundColor: Color(0xFF001122),
  );

  static final desert1 = Track(
    id: 'desert_1',
    nameKo: '사막 듄즈',
    type: TrackType.desert,
    requiredLeague: 2, // Silver
    unlockCost: 500,
    size: Vector2(1400, 900),
    centerLine: [
      Vector2(200, 450),
      Vector2(500, 200),
      Vector2(900, 300),
      Vector2(1100, 600),
      Vector2(700, 700),
      Vector2(300, 600),
      Vector2(200, 450),
    ],
    trackWidth: 130,
    checkpoints: [
      Checkpoint(position: Vector2(450, 150), width: 100, height: 20, index: 0),
      Checkpoint(position: Vector2(1050, 550), width: 20, height: 100, index: 1),
      Checkpoint(position: Vector2(650, 720), width: 100, height: 20, index: 2),
      Checkpoint(position: Vector2(150, 400), width: 20, height: 100, index: 3),
    ],
    startPosition: Vector2(200, 450),
    startAngle: 0,
    roadColor: Color(0xFFCC9966),
    borderColor: Color(0xFF996633),
    backgroundColor: Color(0xFFFFDD99),
  );

  static final snow1 = Track(
    id: 'snow_1',
    nameKo: '프로즌 피크',
    type: TrackType.snow,
    requiredLeague: 3, // Gold
    unlockCost: 1000,
    size: Vector2(1300, 1000),
    centerLine: [
      Vector2(250, 500),
      Vector2(450, 250),
      Vector2(850, 300),
      Vector2(1000, 600),
      Vector2(750, 800),
      Vector2(400, 750),
      Vector2(250, 500),
    ],
    trackWidth: 110,
    checkpoints: [
      Checkpoint(position: Vector2(400, 200), width: 100, height: 20, index: 0),
      Checkpoint(position: Vector2(950, 550), width: 20, height: 100, index: 1),
      Checkpoint(position: Vector2(700, 820), width: 100, height: 20, index: 2),
      Checkpoint(position: Vector2(200, 450), width: 20, height: 100, index: 3),
    ],
    startPosition: Vector2(250, 500),
    startAngle: 0,
    roadColor: Color(0xFFDDDDFF),
    borderColor: Color(0xFF6666FF),
    backgroundColor: Color(0xFFEEEEFF),
  );

  static final jungle1 = Track(
    id: 'jungle_1',
    nameKo: '정글 러쉬',
    type: TrackType.jungle,
    requiredLeague: 3, // Gold
    unlockCost: 1200,
    size: Vector2(1500, 1000),
    centerLine: [
      Vector2(300, 500),
      Vector2(600, 250),
      Vector2(1000, 350),
      Vector2(1200, 650),
      Vector2(900, 800),
      Vector2(500, 700),
      Vector2(300, 500),
    ],
    trackWidth: 100,
    checkpoints: [
      Checkpoint(position: Vector2(550, 200), width: 100, height: 20, index: 0),
      Checkpoint(position: Vector2(1150, 600), width: 20, height: 100, index: 1),
      Checkpoint(position: Vector2(850, 820), width: 100, height: 20, index: 2),
      Checkpoint(position: Vector2(250, 450), width: 20, height: 100, index: 3),
    ],
    startPosition: Vector2(300, 500),
    startAngle: 0,
    roadColor: Color(0xFF556633),
    borderColor: Color(0xFF88AA44),
    backgroundColor: Color(0xFF224411),
  );

  static final volcanic1 = Track(
    id: 'volcanic_1',
    nameKo: '화산 인페르노',
    type: TrackType.volcanic,
    requiredLeague: 4, // Platinum
    unlockCost: 2000,
    size: Vector2(1400, 1100),
    centerLine: [
      Vector2(250, 550),
      Vector2(550, 300),
      Vector2(950, 400),
      Vector2(1100, 700),
      Vector2(800, 900),
      Vector2(400, 800),
      Vector2(250, 550),
    ],
    trackWidth: 115,
    checkpoints: [
      Checkpoint(position: Vector2(500, 250), width: 100, height: 20, index: 0),
      Checkpoint(position: Vector2(1050, 650), width: 20, height: 100, index: 1),
      Checkpoint(position: Vector2(750, 920), width: 100, height: 20, index: 2),
      Checkpoint(position: Vector2(200, 500), width: 20, height: 100, index: 3),
    ],
    startPosition: Vector2(250, 550),
    startAngle: 0,
    roadColor: Color(0xFF442211),
    borderColor: Color(0xFFFF4400),
    backgroundColor: Color(0xFF331100),
  );

  static final space1 = Track(
    id: 'space_1',
    nameKo: '코즈믹 스피드웨이',
    type: TrackType.space,
    requiredLeague: 4, // Platinum
    unlockCost: 2500,
    size: Vector2(1600, 1200),
    centerLine: [
      Vector2(300, 600),
      Vector2(700, 300),
      Vector2(1100, 400),
      Vector2(1300, 800),
      Vector2(900, 1000),
      Vector2(500, 850),
      Vector2(300, 600),
    ],
    trackWidth: 120,
    checkpoints: [
      Checkpoint(position: Vector2(650, 250), width: 100, height: 20, index: 0),
      Checkpoint(position: Vector2(1250, 750), width: 20, height: 100, index: 1),
      Checkpoint(position: Vector2(850, 1020), width: 100, height: 20, index: 2),
      Checkpoint(position: Vector2(250, 550), width: 20, height: 100, index: 3),
    ],
    startPosition: Vector2(300, 600),
    startAngle: 0,
    roadColor: Color(0xFF222244),
    borderColor: Color(0xFF00FFFF),
    backgroundColor: Color(0xFF000011),
  );

  static final underwater1 = Track(
    id: 'underwater_1',
    nameKo: '딥 블루 드리프트',
    type: TrackType.underwater,
    requiredLeague: 5, // Legend
    unlockCost: 3500,
    size: Vector2(1500, 1200),
    centerLine: [
      Vector2(300, 600),
      Vector2(650, 350),
      Vector2(1050, 450),
      Vector2(1200, 750),
      Vector2(850, 950),
      Vector2(450, 850),
      Vector2(300, 600),
    ],
    trackWidth: 125,
    checkpoints: [
      Checkpoint(position: Vector2(600, 300), width: 100, height: 20, index: 0),
      Checkpoint(position: Vector2(1150, 700), width: 20, height: 100, index: 1),
      Checkpoint(position: Vector2(800, 970), width: 100, height: 20, index: 2),
      Checkpoint(position: Vector2(250, 550), width: 20, height: 100, index: 3),
    ],
    startPosition: Vector2(300, 600),
    startAngle: 0,
    roadColor: Color(0xFF004466),
    borderColor: Color(0xFF0088FF),
    backgroundColor: Color(0xFF001133),
  );

  static final rainbow1 = Track(
    id: 'rainbow_1',
    nameKo: '레인보우 로드',
    type: TrackType.rainbow,
    requiredLeague: 5, // Legend
    unlockCost: 5000,
    size: Vector2(1800, 1400),
    centerLine: [
      Vector2(400, 700),
      Vector2(800, 400),
      Vector2(1200, 500),
      Vector2(1400, 900),
      Vector2(1000, 1100),
      Vector2(600, 1000),
      Vector2(400, 700),
    ],
    trackWidth: 110,
    checkpoints: [
      Checkpoint(position: Vector2(750, 350), width: 100, height: 20, index: 0),
      Checkpoint(position: Vector2(1350, 850), width: 20, height: 100, index: 1),
      Checkpoint(position: Vector2(950, 1120), width: 100, height: 20, index: 2),
      Checkpoint(position: Vector2(350, 650), width: 20, height: 100, index: 3),
    ],
    startPosition: Vector2(400, 700),
    startAngle: 0,
    roadColor: Color(0xFFFF00FF),
    borderColor: Color(0xFFFFFF00),
    backgroundColor: Color(0xFF6600FF),
  );

  static final List<Track> all = [
    city1,
    desert1,
    snow1,
    jungle1,
    volcanic1,
    space1,
    underwater1,
    rainbow1,
  ];

  static Track? getById(String id) {
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
