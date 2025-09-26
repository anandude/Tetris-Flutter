class GameConfig {
  const GameConfig({
    this.columns = 10,
    this.rows = 20,
    this.initialDropIntervalMs = 800,
    this.minimumDropIntervalMs = 100,
    this.speedIncreaseFactor = 0.9,
  });

  final int columns;
  final int rows;
  final int initialDropIntervalMs;
  final int minimumDropIntervalMs;
  final double speedIncreaseFactor;
}

