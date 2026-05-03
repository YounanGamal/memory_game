import 'dart:async';
import 'dart:math' as math;

import 'package:get/get.dart';
import '../core/enums/game_enums.dart';
import '../core/services/sound_service.dart';
import '../models/card_model.dart';

class GameController extends GetxController {
  final Rx<GameState> state = GameState.idle.obs;
  final Rx<GameLevel> level = GameLevel.easy.obs;
  final Rx<GameMode> mode = GameMode.classic.obs;

  final RxList<CardModel> cards = <CardModel>[].obs;
  final RxInt moves = 0.obs;
  final RxInt secondsElapsed = 0.obs;
  final RxInt remainingSeconds = 0.obs;
  final RxInt matchesFound = 0.obs;
  final RxInt score = 0.obs;
  final RxInt combo = 1.obs;
  final RxInt bestCombo = 1.obs;
  final RxInt hintsLeft = 0.obs;
  final RxInt autoMatchesLeft = 0.obs;
  final RxInt hintCooldown = 0.obs;
  final RxInt autoMatchCooldown = 0.obs;

  DateTime? _lastMatchTime;
  Timer? _timer;
  Timer? _hintCooldownTimer;
  Timer? _autoMatchCooldownTimer;
  CardModel? _firstSelectedCard;
  bool _isProcessing = false;
  int _previewToken = 0;

  static const int _comboThresholdSeconds = 5;
  static const int _assistCooldownSeconds = 3;
  static const int _autoMatchPenalty = 50;

  bool get isTimeAttack => mode.value == GameMode.timeAttack;
  bool get hasAssists => mode.value == GameMode.assist;
  bool get canUseHint =>
      hasAssists &&
      state.value == GameState.playing &&
      !_isProcessing &&
      hintsLeft.value > 0 &&
      hintCooldown.value == 0;
  bool get canUseAutoMatch =>
      hasAssists &&
      state.value == GameState.playing &&
      !_isProcessing &&
      autoMatchesLeft.value > 0 &&
      autoMatchCooldown.value == 0;

  final List<String> _emojiPool = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐮',
    '🐷',
    '🐸',
    '🐵',
    '🐔',
    '🐧',
    '🐦',
    '🐤',
    '🦆',
    '🦅',
    '🦉',
    '🦇',
    '🐺',
    '🐗',
    '🐴',
    '🦄',
    '🐝',
    '🐛',
    '🦋',
    '🐌',
    '🐞',
    '🐜',
    '🦟',
    '🐢',
    '🐍',
    '🦎',
    '🦖',
    '🦕',
    '🐙',
    '🦑',
    '🦐',
    '🦞',
    '🦀',
    '🐡',
    '🐠',
    '🐟',
    '🐬',
    '🐳',
    '🐋',
    '🦈',
    '🐊',
    '🐅',
    '🐆',
    '🦓',
    '🦍',
    '🦧',
    '🐘',
    '🦛',
    '🦏',
    '🐪',
    '🐫',
    '🦒',
    '🦘',
    '🐃',
    '🐂',
    '🐄',
    '🐎',
    '🐖',
    '🐏',
    '🐑',
    '🐐',
    '🦌',
    '🐕',
    '🐩',
    '🐈',
    '🐓',
    '🦃',
    '🦚',
    '🦜',
    '🦢',
    '🦩',
    '🕊',
    '🐇',
    '🦝',
    '🦨',
    '🦡',
    '🦦',
    '🦥',
    '🐁',
    '🐀',
    '🐿',
    '🦔',
    '🐾',
    '🐉',
    '🐲',
    '🌵',
    '🎄',
    '🌲',
    '🌳',
  ];

  void startGame(
    GameLevel selectedLevel, [
    GameMode selectedMode = GameMode.classic,
  ]) async {
    final token = ++_previewToken;
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    _autoMatchCooldownTimer?.cancel();

    level.value = selectedLevel;
    mode.value = selectedMode;
    _generateBoard();
    moves.value = 0;
    secondsElapsed.value = 0;
    remainingSeconds.value = selectedLevel.timeLimit;
    matchesFound.value = 0;
    score.value = 0;
    combo.value = 1;
    bestCombo.value = 1;
    hintsLeft.value = selectedMode == GameMode.assist ? 1 : 0;
    autoMatchesLeft.value = selectedMode == GameMode.assist ? 1 : 0;
    hintCooldown.value = 0;
    autoMatchCooldown.value = 0;
    _lastMatchTime = null;
    _firstSelectedCard = null;
    _isProcessing = false;

    // Start Preview
    state.value = GameState.preview;
    for (var card in cards) {
      card.isFlipped.value = true;
    }

    await Future.delayed(Duration(seconds: level.value.previewDuration));
    if (token != _previewToken) return;

    for (var card in cards) {
      card.isFlipped.value = false;
    }

    state.value = GameState.playing;
    _startTimer();
  }

  void _generateBoard() {
    int totalCards = level.value.gridSize * level.value.gridSize;
    int pairsNeeded = totalCards ~/ 2;

    List<String> selectedEmojis = (_emojiPool..shuffle())
        .take(pairsNeeded)
        .toList();
    List<String> gameEmojis = [...selectedEmojis, ...selectedEmojis]..shuffle();

    cards.value = List.generate(totalCards, (index) {
      return CardModel(id: index, value: gameEmojis[index]);
    });
  }

  void onCardTap(CardModel card) {
    if (state.value != GameState.playing ||
        _isProcessing ||
        card.isFlipped.value ||
        card.isMatched.value) {
      return;
    }

    card.isFlipped.value = true;
    SoundService.playFlip();

    if (_firstSelectedCard == null) {
      _firstSelectedCard = card;
    } else {
      _compareCards(card);
    }
  }

  Future<void> useHint() async {
    if (!canUseHint || state.value != GameState.playing || _isProcessing)
      return;

    hintsLeft.value--;
    _startCooldown(hintCooldown, (timer) => _hintCooldownTimer = timer);
    _firstSelectedCard = null;
    _isProcessing = true;
    state.value = GameState.preview;
    SoundService.playFlip();

    for (final card in cards) {
      if (!card.isMatched.value) {
        card.isFlipped.value = true;
      }
    }

    // Wait for the duration of the cooldown so the timer acts as a visual countdown
    await Future.delayed(Duration(seconds: _assistCooldownSeconds));

    for (final card in cards) {
      if (!card.isMatched.value) {
        card.isFlipped.value = false;
      }
    }

    _isProcessing = false;
    state.value = GameState.playing;
  }

  Future<void> useAutoMatch() async {
    if (!canUseAutoMatch || state.value != GameState.playing || _isProcessing)
      return;

    final pair = _findUnmatchedPair();
    if (pair == null) return;

    autoMatchesLeft.value--;
    if (autoMatchesLeft.value > 0) {
      _startCooldown(
        autoMatchCooldown,
        (timer) => _autoMatchCooldownTimer = timer,
      );
    }
    _firstSelectedCard = null;
    _isProcessing = true;
    moves.value++;

    final first = pair.$1;
    final second = pair.$2;
    first.isFlipped.value = true;
    second.isFlipped.value = true;
    SoundService.playFlip();

    await Future.delayed(const Duration(milliseconds: 350));

    first.isMatched.value = true;
    second.isMatched.value = true;
    matchesFound.value++;
    _handleMatch();
    score.value = math.max(0, score.value - _autoMatchPenalty);
    SoundService.playMatch();

    _isProcessing = false;
    _checkWin();
  }

  void _compareCards(CardModel secondCard) async {
    _isProcessing = true;
    moves.value++;

    if (_firstSelectedCard!.value == secondCard.value) {
      // Match!
      _firstSelectedCard!.isMatched.value = true;
      secondCard.isMatched.value = true;
      matchesFound.value++;

      _handleMatch();
      SoundService.playMatch();

      _firstSelectedCard = null;
      _isProcessing = false;

      _checkWin();
    } else {
      // No match
      state.value = GameState.comparing;
      _firstSelectedCard!.isWrong.value = true;
      secondCard.isWrong.value = true;
      combo.value = 1; // Reset combo on mismatch

      SoundService.playWrong();

      await Future.delayed(const Duration(milliseconds: 600));

      _firstSelectedCard!.isFlipped.value = false;
      secondCard.isFlipped.value = false;
      _firstSelectedCard!.isWrong.value = false;
      secondCard.isWrong.value = false;

      _firstSelectedCard = null;
      _isProcessing = false;
      state.value = GameState.playing;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.value == GameState.playing) {
        if (isTimeAttack) {
          remainingSeconds.value--;
          if (remainingSeconds.value <= 0) {
            remainingSeconds.value = 0;
            _loseGame();
          }
        } else {
          secondsElapsed.value++;
        }
      } else if (state.value == GameState.finished ||
          state.value == GameState.lost) {
        timer.cancel();
      }
    });
  }

  void _startCooldown(RxInt target, void Function(Timer timer) storeTimer) {
    target.value = _assistCooldownSeconds;
    late Timer timer;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (target.value <= 1) {
        target.value = 0;
        timer.cancel();
      } else {
        target.value--;
      }
    });
    storeTimer(timer);
  }

  (CardModel, CardModel)? _findUnmatchedPair() {
    final unmatched = cards.where((card) => !card.isMatched.value).toList();
    for (var i = 0; i < unmatched.length; i++) {
      for (var j = i + 1; j < unmatched.length; j++) {
        if (unmatched[i].value == unmatched[j].value) {
          return (unmatched[i], unmatched[j]);
        }
      }
    }
    return null;
  }

  void _checkWin() {
    if (matchesFound.value ==
        (level.value.gridSize * level.value.gridSize) ~/ 2) {
      _winGame();
    }
  }

  void _handleMatch() {
    final now = DateTime.now();
    if (_lastMatchTime != null) {
      final difference = now.difference(_lastMatchTime!).inSeconds;
      if (difference <= _comboThresholdSeconds) {
        combo.value++;
      } else {
        combo.value = 1;
      }
    }
    if (combo.value > bestCombo.value) {
      bestCombo.value = combo.value;
    }
    _lastMatchTime = now;

    // Calculate score: Base points * combo - small penalty for time
    int basePoints = 100;
    int pointsGained = basePoints * combo.value;
    score.value += pointsGained;
  }

  void _winGame() {
    // Add bonus for finishing fast
    final elapsed = isTimeAttack
        ? level.value.timeLimit - remainingSeconds.value
        : secondsElapsed.value;
    int timeBonus = (300 - elapsed).clamp(0, 1000);
    score.value += timeBonus;

    SoundService.playWin();

    state.value = GameState.finished;
    _timer?.cancel();
  }

  void _loseGame() {
    state.value = GameState.lost;
    _timer?.cancel();
    _isProcessing = false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    _autoMatchCooldownTimer?.cancel();
    SoundService.dispose();
    super.onClose();
  }
}
