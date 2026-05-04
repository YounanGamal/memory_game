enum GameState { idle, preview, playing, comparing, finished, lost }

enum GameMode {
  classic(label: 'Classic', details: 'Pure memory challenge'),
  timeAttack(label: 'Time Attack', details: 'Beat the countdown');

  final String label;
  final String details;

  const GameMode({required this.label, required this.details});
}

enum GameLevel {
  classic1(
    mode: GameMode.classic,
    number: 1,
    rows: 2,
    columns: 2,
    previewDuration: 3,
    timeLimit: 20,
  ),
  classic2(
    mode: GameMode.classic,
    number: 2,
    rows: 2,
    columns: 3,
    previewDuration: 3,
    timeLimit: 30,
  ),
  classic3(
    mode: GameMode.classic,
    number: 3,
    rows: 2,
    columns: 4,
    previewDuration: 3,
    timeLimit: 45,
  ),
  classic4(
    mode: GameMode.classic,
    number: 4,
    rows: 3,
    columns: 4,
    previewDuration: 3,
    timeLimit: 65,
  ),
  classic5(
    mode: GameMode.classic,
    number: 5,
    rows: 4,
    columns: 4,
    previewDuration: 2,
    timeLimit: 85,
  ),
  classic6(
    mode: GameMode.classic,
    number: 6,
    rows: 4,
    columns: 5,
    previewDuration: 2,
    timeLimit: 105,
  ),
  classic7(
    mode: GameMode.classic,
    number: 7,
    rows: 4,
    columns: 6,
    previewDuration: 2,
    timeLimit: 125,
  ),
  classic8(
    mode: GameMode.classic,
    number: 8,
    rows: 5,
    columns: 6,
    previewDuration: 2,
    timeLimit: 150,
  ),
  classic9(
    mode: GameMode.classic,
    number: 9,
    rows: 6,
    columns: 6,
    previewDuration: 2,
    timeLimit: 175,
  ),
  classic10(
    mode: GameMode.classic,
    number: 10,
    rows: 8,
    columns: 6,
    previewDuration: 2,
    timeLimit: 220,
  ),
  timeAttack1(
    mode: GameMode.timeAttack,
    number: 1,
    rows: 2,
    columns: 2,
    previewDuration: 2,
    timeLimit: 18,
  ),
  timeAttack2(
    mode: GameMode.timeAttack,
    number: 2,
    rows: 2,
    columns: 3,
    previewDuration: 2,
    timeLimit: 24,
  ),
  timeAttack3(
    mode: GameMode.timeAttack,
    number: 3,
    rows: 2,
    columns: 4,
    previewDuration: 2,
    timeLimit: 34,
  ),
  timeAttack4(
    mode: GameMode.timeAttack,
    number: 4,
    rows: 3,
    columns: 4,
    previewDuration: 2,
    timeLimit: 50,
  ),
  timeAttack5(
    mode: GameMode.timeAttack,
    number: 5,
    rows: 4,
    columns: 4,
    previewDuration: 2,
    timeLimit: 68,
  ),
  timeAttack6(
    mode: GameMode.timeAttack,
    number: 6,
    rows: 4,
    columns: 5,
    previewDuration: 2,
    timeLimit: 85,
  ),
  timeAttack7(
    mode: GameMode.timeAttack,
    number: 7,
    rows: 4,
    columns: 6,
    previewDuration: 2,
    timeLimit: 100,
  ),
  timeAttack8(
    mode: GameMode.timeAttack,
    number: 8,
    rows: 5,
    columns: 6,
    previewDuration: 2,
    timeLimit: 120,
  ),
  timeAttack9(
    mode: GameMode.timeAttack,
    number: 9,
    rows: 6,
    columns: 6,
    previewDuration: 2,
    timeLimit: 145,
  ),
  timeAttack10(
    mode: GameMode.timeAttack,
    number: 10,
    rows: 8,
    columns: 6,
    previewDuration: 2,
    timeLimit: 180,
  );

  final GameMode mode;
  final int number;
  final int rows;
  final int columns;
  final int previewDuration;
  final int timeLimit;

  const GameLevel({
    required this.mode,
    required this.number,
    required this.rows,
    required this.columns,
    required this.previewDuration,
    required this.timeLimit,
  });

  String get label => 'Level $number';
  String get gridLabel => '$rows x $columns';
  int get totalCards => rows * columns;
  int get pairsCount => totalCards ~/ 2;
  bool get hasNext => number < mode.levels.length;

  GameLevel? get nextLevel {
    if (!hasNext) return null;
    return mode.levels[number];
  }
}

extension GameModeLevels on GameMode {
  List<GameLevel> get levels {
    return GameLevel.values.where((level) => level.mode == this).toList();
  }

  GameLevel get firstLevel => levels.first;
}

enum PowerUpType {
  reveal(label: 'Reveal', cost: 30),
  autoMatch(label: 'Auto Match', cost: 45),
  slowTime(label: 'Slow Time', cost: 40),
  highlight(label: 'Highlight', cost: 25);

  final String label;
  final int cost;

  const PowerUpType({required this.label, required this.cost});
}
