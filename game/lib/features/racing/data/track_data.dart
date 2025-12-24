import '../models/track.dart';

class TrackData {
  static const Track beginnerLoop = Track(
    id: 't_beginner',
    name: 'Beginner Loop',
    lengthMeters: 800,
    complexity: 1.0,
    difficultyRating: 1, // Easy
  );

  static const Track desertRally = Track(
    id: 't_desert',
    name: 'Desert Rally',
    lengthMeters: 1500,
    complexity: 1.5,
    difficultyRating: 2, // Medium
  );

  static const Track mountainPeak = Track(
    id: 't_mountain',
    name: 'Mountain Peak',
    lengthMeters: 2200,
    complexity: 2.0,
    difficultyRating: 3, // Hard
  );

  static List<Track> getAllTracks() {
    return [beginnerLoop, desertRally, mountainPeak];
  }
}
