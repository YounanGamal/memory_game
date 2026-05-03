enum GameState { idle, preview, playing, comparing, finished }

enum GameLevel {
  easy(gridSize: 2, previewDuration: 3),
  medium(gridSize: 4, previewDuration: 2),
  hard(gridSize: 6, previewDuration: 1);

  final int gridSize;
  final int previewDuration;

  const GameLevel({required this.gridSize, required this.previewDuration});
}
