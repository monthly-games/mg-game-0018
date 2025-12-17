import 'dart:ui';
import 'package:flame/components.dart';
import '../tracks/track_data.dart';

/// Track rendering component
class TrackComponent extends Component {
  final Track track;

  TrackComponent({required this.track});

  @override
  void render(Canvas canvas) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, track.size.x, track.size.y),
      Paint()..color = track.backgroundColor,
    );

    // Draw track path
    _drawTrackPath(canvas);

    // Draw checkpoints (debug)
    _drawCheckpoints(canvas);

    // Draw start/finish line
    _drawStartLine(canvas);
  }

  void _drawTrackPath(Canvas canvas) {
    if (track.centerLine.length < 2) return;

    final roadPaint = Paint()
      ..color = track.roadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = track.trackWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final borderPaint = Paint()
      ..color = track.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = track.trackWidth + 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Create path
    final path = Path();
    path.moveTo(track.centerLine.first.x, track.centerLine.first.y);
    for (int i = 1; i < track.centerLine.length; i++) {
      path.lineTo(track.centerLine[i].x, track.centerLine[i].y);
    }
    // Close the loop
    path.lineTo(track.centerLine.first.x, track.centerLine.first.y);

    // Draw border first (underneath)
    canvas.drawPath(path, borderPaint);

    // Draw road on top
    canvas.drawPath(path, roadPaint);

    // Draw center dashed line
    _drawDashedCenterLine(canvas);
  }

  void _drawDashedCenterLine(Canvas canvas) {
    final dashPaint = Paint()
      ..color = const Color(0x88FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < track.centerLine.length; i++) {
      final start = track.centerLine[i];
      final end = track.centerLine[(i + 1) % track.centerLine.length];

      _drawDashedLine(canvas, start, end, dashPaint, dashLength: 20, gapLength: 15);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint, {
    double dashLength = 10,
    double gapLength = 5,
  }) {
    final totalLength = (end - start).length;
    final direction = (end - start).normalized();

    double distance = 0;
    bool drawing = true;

    while (distance < totalLength) {
      final segmentLength = drawing ? dashLength : gapLength;
      final nextDistance = (distance + segmentLength).clamp(0.0, totalLength);

      if (drawing) {
        final p1 = start + direction * distance;
        final p2 = start + direction * nextDistance;
        canvas.drawLine(
          Offset(p1.x, p1.y),
          Offset(p2.x, p2.y),
          paint,
        );
      }

      distance = nextDistance.toDouble();
      drawing = !drawing;
    }
  }

  void _drawCheckpoints(Canvas canvas) {
    final checkpointPaint = Paint()
      ..color = const Color(0x44FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final checkpoint in track.checkpoints) {
      canvas.drawRect(
        Rect.fromLTWH(
          checkpoint.position.x,
          checkpoint.position.y,
          checkpoint.width,
          checkpoint.height,
        ),
        checkpointPaint,
      );
    }
  }

  void _drawStartLine(Canvas canvas) {
    // Start/finish line (checkpoint 0 area)
    final startCheckpoint = track.checkpoints.first;

    final finishPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    // Checkered pattern
    final squareSize = 10.0;
    bool white = true;

    for (double x = startCheckpoint.position.x;
         x < startCheckpoint.position.x + startCheckpoint.width;
         x += squareSize) {
      for (double y = startCheckpoint.position.y;
           y < startCheckpoint.position.y + startCheckpoint.height;
           y += squareSize) {
        if (white) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, squareSize, squareSize),
            finishPaint,
          );
        }
        white = !white;
      }
      white = !white;
    }
  }
}
