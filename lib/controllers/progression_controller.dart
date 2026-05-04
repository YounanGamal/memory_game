import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/enums/game_enums.dart';
import '../models/reward_result.dart';

class ProgressionController extends GetxController {
  static const String _coinsKey = 'progression_coins';
  static const String _starsKey = 'progression_total_stars';
  static const String _winsKey = 'progression_wins';
  static const String _gamesKey = 'progression_games';
  static const String _bestScoreKey = 'progression_best_score';
  static const String _bestTimeKey = 'progression_best_time';
  static const String _perfectWinsKey = 'progression_perfect_wins';

  final RxInt coins = 0.obs;
  final RxInt totalStars = 0.obs;
  final RxInt wins = 0.obs;
  final RxInt gamesPlayed = 0.obs;
  final RxInt bestScore = 0.obs;
  final RxInt bestTimeSeconds = 0.obs;
  final RxInt perfectWins = 0.obs;
  final RxMap<String, int> powerUps = <String, int>{}.obs;
  final RxMap<String, int> bestStarsByLevel = <String, int>{}.obs;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    coins.value = preferences.getInt(_coinsKey) ?? 60;
    totalStars.value = preferences.getInt(_starsKey) ?? 0;
    wins.value = preferences.getInt(_winsKey) ?? 0;
    gamesPlayed.value = preferences.getInt(_gamesKey) ?? 0;
    bestScore.value = preferences.getInt(_bestScoreKey) ?? 0;
    bestTimeSeconds.value = preferences.getInt(_bestTimeKey) ?? 0;
    perfectWins.value = preferences.getInt(_perfectWinsKey) ?? 0;

    powerUps.value = {
      for (final type in PowerUpType.values)
        type.name: preferences.getInt(_powerUpKey(type)) ?? 0,
    };

    bestStarsByLevel.value = {
      for (final level in GameLevel.values)
        level.name: preferences.getInt(_levelStarsKey(level)) ?? 0,
    };
  }

  int countFor(PowerUpType type) => powerUps[type.name] ?? 0;

  bool canBuy(PowerUpType type) => coins.value >= type.cost;

  Future<bool> buyPowerUp(PowerUpType type) async {
    if (!canBuy(type)) return false;

    coins.value -= type.cost;
    powerUps[type.name] = countFor(type) + 1;
    await _saveWalletAndPowerUp(type);
    return true;
  }

  Future<bool> consumePowerUp(PowerUpType type) async {
    final currentCount = countFor(type);
    if (currentCount <= 0) return false;

    powerUps[type.name] = currentCount - 1;
    await _savePowerUp(type);
    return true;
  }

  Future<RewardResult> recordWin({
    required GameLevel level,
    required GameMode mode,
    required int score,
    required int moves,
    required int elapsedSeconds,
    required int wrongAttempts,
  }) async {
    final stars = _calculateStars(
      level: level,
      moves: moves,
      elapsedSeconds: elapsedSeconds,
    );
    final earnedCoins = _calculateCoins(
      level: level,
      stars: stars,
      moves: moves,
      elapsedSeconds: elapsedSeconds,
      wrongAttempts: wrongAttempts,
    );

    final oldBestStars = bestStarsByLevel[level.name] ?? 0;
    final newStars = math.max(0, stars - oldBestStars);
    final isBestScore = score > bestScore.value;
    final isBestTime =
        bestTimeSeconds.value == 0 || elapsedSeconds < bestTimeSeconds.value;

    coins.value += earnedCoins;
    totalStars.value += newStars;
    wins.value++;
    gamesPlayed.value++;
    if (wrongAttempts == 0) perfectWins.value++;
    if (stars > oldBestStars) bestStarsByLevel[level.name] = stars;
    if (isBestScore) bestScore.value = score;
    if (isBestTime) bestTimeSeconds.value = elapsedSeconds;

    await _saveProgress(level);

    return RewardResult(
      coins: earnedCoins,
      stars: stars,
      isBestScore: isBestScore,
      isBestTime: isBestTime,
    );
  }

  Future<void> recordLoss() async {
    gamesPlayed.value++;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_gamesKey, gamesPlayed.value);
  }

  int _calculateStars({
    required GameLevel level,
    required int moves,
    required int elapsedSeconds,
  }) {
    final pairs = (level.gridSize * level.gridSize) ~/ 2;
    final excellentMoves = pairs + 2;
    final goodMoves = (pairs * 2.2).ceil();
    final excellentTime = (level.timeLimit * 0.45).ceil();
    final goodTime = (level.timeLimit * 0.75).ceil();

    if (moves <= excellentMoves && elapsedSeconds <= excellentTime) return 3;
    if (moves <= goodMoves && elapsedSeconds <= goodTime) return 2;
    return 1;
  }

  int _calculateCoins({
    required GameLevel level,
    required int stars,
    required int moves,
    required int elapsedSeconds,
    required int wrongAttempts,
  }) {
    final pairs = (level.gridSize * level.gridSize) ~/ 2;
    final moveBonus = math.max(0, (pairs * 3) - moves) * 2;
    final timeBonus = math.max(0, level.timeLimit - elapsedSeconds) ~/ 4;
    final mistakePenalty = wrongAttempts * 3;
    return math.max(10, (stars * 20) + moveBonus + timeBonus - mistakePenalty);
  }

  Future<void> _saveProgress(GameLevel level) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_coinsKey, coins.value);
    await preferences.setInt(_starsKey, totalStars.value);
    await preferences.setInt(_winsKey, wins.value);
    await preferences.setInt(_gamesKey, gamesPlayed.value);
    await preferences.setInt(_bestScoreKey, bestScore.value);
    await preferences.setInt(_bestTimeKey, bestTimeSeconds.value);
    await preferences.setInt(_perfectWinsKey, perfectWins.value);
    await preferences.setInt(
      _levelStarsKey(level),
      bestStarsByLevel[level.name] ?? 0,
    );
  }

  Future<void> _saveWalletAndPowerUp(PowerUpType type) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_coinsKey, coins.value);
    await preferences.setInt(_powerUpKey(type), countFor(type));
  }

  Future<void> _savePowerUp(PowerUpType type) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_powerUpKey(type), countFor(type));
  }

  static String _powerUpKey(PowerUpType type) => 'power_up_${type.name}';
  static String _levelStarsKey(GameLevel level) => 'best_stars_${level.name}';
}
