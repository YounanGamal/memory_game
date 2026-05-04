enum GameState { idle, preview, playing, comparing, finished, lost }

enum GameMode {
  classic(label: 'Classic', details: 'Pure memory challenge'),
  assist(label: 'Assist', details: '1 hint + 1 auto match'),
  timeAttack(label: 'Time Attack', details: 'Beat the countdown');

  final String label;
  final String details;

  const GameMode({required this.label, required this.details});
}

enum GameLevel {
  easy(gridSize: 2, previewDuration: 3, timeLimit: 15),
  medium(gridSize: 4, previewDuration: 2, timeLimit: 90),
  hard(gridSize: 6, previewDuration: 1, timeLimit: 120);

  final int gridSize;
  final int previewDuration;
  final int timeLimit;

  const GameLevel({
    required this.gridSize,
    required this.previewDuration,
    required this.timeLimit,
  });
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
