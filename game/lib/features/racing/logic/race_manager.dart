class RaceManager {
  final int defaultLapCount;
  int _currentLap = 1;
  int _totalCheckpoints = 0;
  int _passedCheckpoints = 0;
  double _raceTime = 0;

  RaceManager({required this.defaultLapCount});

  int get currentLap => _currentLap;
  int get totalCheckpoints => _totalCheckpoints;
  int get passedCheckpoints => _passedCheckpoints;
  double get raceTime => _raceTime;

  void startRace() {
    _currentLap = 1;
    _passedCheckpoints = 0;
    _raceTime = 0;
  }

  void passCheckpoint() {
    _passedCheckpoints++;
    if (_passedCheckpoints >= _totalCheckpoints) {
      _currentLap++;
      _passedCheckpoints = 0;
    }
  }

  void setTotalCheckpoints(int count) {
    _totalCheckpoints = count;
  }

  void update(double deltaTime) {
    _raceTime += deltaTime;
  }

  bool isRaceFinished() {
    return _currentLap > defaultLapCount;
  }
}
