class Track {
  final String id;
  final String name;
  final int lengthMeters;
  final double complexity; // 1.0 = straight, 2.0 = very curvy
  final int difficultyRating; // 1 = Easy, 2 = Medium, 3 = Hard

  const Track({
    required this.id,
    required this.name,
    required this.lengthMeters,
    this.complexity = 1.0,
    this.difficultyRating = 1,
  });
}
