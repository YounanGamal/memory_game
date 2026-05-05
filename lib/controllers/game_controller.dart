import 'dart:async';
import 'dart:math' as math;

import 'package:get/get.dart';
import '../core/enums/game_enums.dart';
import '../core/services/sound_service.dart';
import '../models/card_model.dart';
import '../models/reward_result.dart';
import 'progression_controller.dart';

class GameController extends GetxController {
  final ProgressionController progression = Get.find<ProgressionController>();

  final Rx<GameState> state = GameState.idle.obs;
  final Rx<GameLevel> level = GameLevel.classic1.obs;
  final Rx<GameMode> mode = GameMode.classic.obs;

  final RxList<CardModel> cards = <CardModel>[].obs;
  final RxInt moves = 0.obs;
  final RxInt secondsElapsed = 0.obs;
  final RxInt remainingSeconds = 0.obs;
  final RxInt matchesFound = 0.obs;
  final RxInt score = 0.obs;
  final RxInt combo = 1.obs;
  final RxInt bestCombo = 1.obs;
  final RxInt autoMatchCooldown = 0.obs;
  final RxInt wrongAttempts = 0.obs;
  final RxInt revealCooldown = 0.obs;
  final RxInt slowTimeCooldown = 0.obs;
  final RxInt highlightCooldown = 0.obs;
  final RxInt slowTimeSeconds = 0.obs;
  final Rxn<RewardResult> lastReward = Rxn<RewardResult>();

  DateTime? _lastMatchTime;
  Timer? _timer;
  Timer? _autoMatchCooldownTimer;
  Timer? _revealCooldownTimer;
  Timer? _slowTimeCooldownTimer;
  Timer? _highlightCooldownTimer;
  Timer? _slowTimeTimer;
  CardModel? _firstSelectedCard;
  bool _isProcessing = false;
  int _previewToken = 0;
  int _timerTicks = 0;
  int _wrongAttemptsThisGame = 0;
  int _consecutiveWrongForSound = 0;

  static const int _comboThresholdSeconds = 5;
  static const int _autoMatchPenalty = 50;
  static const int _failSoundAttemptThreshold = 3;
  static const int _powerUpCooldownSeconds = 8;
  static const int _slowTimeDurationSeconds = 10;

  bool get isTimeAttack => mode.value == GameMode.timeAttack;

  bool canUsePowerUp(PowerUpType type) {
    if (type == PowerUpType.slowTime && !isTimeAttack) return false;

    return state.value == GameState.playing &&
        !_isProcessing &&
        progression.countFor(type) > 0 &&
        _cooldownFor(type).value == 0;
  }

  final List<String> _emojiPool = [
    // Animals
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
    '🦁', '🐮', '🐷', '🐸', '🐵', '🐔', '🐧', '🐦', '🐤', '🦆',
    '🦅', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛', '🦋',
    '🐌', '🐞', '🐜', '🦟', '🐢', '🐍', '🦎', '🦖', '🦕', '🐙',
    '🦑', '🦐', '🦞', '🦀', '🐡', '🐠', '🐟', '🐬', '🐳', '🐋',
    '🦈', '🐊', '🐅', '🐆', '🦓', '🦍', '🦧', '🐘', '🦛', '🦏',
    '🐪', '🐫', '🦒', '🦘', '🐃', '🐂', '🐄', '🐎', '🐖', '🐏',
    '🐑', '🐐', '🦌', '🐕', '🐩', '🐈', '🐓', '🦃', '🦚', '🦜',
    '🦢', '🦩', '🕊', '🐇', '🦝', '🦨', '🦡', '🦦', '🦥', '🐁',
    '🐀', '🐿', '🦔', '🐾', '🐉', '🐲',

    // Food
    '🍎', '🍌', '🍇', '🍉', '🍓', '🍒', '🍑', '🍍', '🥭', '🥝',
    '🍅', '🥥', '🥑', '🍆', '🥔', '🥕', '🌽', '🌶', '🥒', '🥬',
    '🥦', '🍄', '🥜', '🍞', '🥐', '🥖', '🥨', '🥯', '🥞', '🧇',
    '🧀', '🍗', '🍖', '🌭', '🍔', '🍟', '🍕', '🥪', '🥙', '🌮',
    '🌯', '🥗', '🍝', '🍜', '🍲', '🍛', '🍣', '🍤', '🍱', '🥟',
    '🍦', '🍩', '🍪', '🎂', '🍰', '🧁', '🍫', '🍬', '🍭', '🍮',

    // Faces
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇',
    '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚',
    '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🥳', '😤', '😡', '😭',

    // Tech
    '💻', '🖥', '🖨', '⌨️', '🖱', '📱', '📲', '☎️', '📞', '📡',
    '📺', '🎮', '🕹', '💾', '💿', '📀', '🔋', '🔌', '💡', '🔦',

    // Sports
    '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏉', '🎱', '🏓', '🏸',
    '🥅', '🏒', '🏑', '🥊', '🥋', '🎯', '⛳', '🏹', '🛹', '🛼',

    // Vehicles
    '🚗', '🚕', '🚙', '🚌', '🚎', '🏎', '🚓', '🚑', '🚒', '🚐',
    '🚚', '🚛', '🚜', '🛵', '🏍', '🚲', '🛴', '✈️', '🚀', '🛸',
    '🚁', '⛵', '🚤', '🛳', '🚢', '🚂', '🚆', '🚇', '🚊', '🚝',

    // Random
    '💎', '🔥', '⭐', '🌟', '✨', '⚡', '🌈', '☀️', '🌙', '☁️',
    '❄️', '☔', '🌊', '🍀', '🌹', '🌻', '🌼', '🌷', '🌺', '🪷',
    '🎁', '🎈', '🎉', '🎊', '🏆', '🥇', '🥈', '🥉', '🎵', '🎶',
  ];

  void startGame(
    GameLevel selectedLevel, [
    GameMode selectedMode = GameMode.classic,
  ]) async {
    final token = ++_previewToken;
    _timer?.cancel();
    _autoMatchCooldownTimer?.cancel();
    _revealCooldownTimer?.cancel();
    _slowTimeCooldownTimer?.cancel();
    _highlightCooldownTimer?.cancel();
    _slowTimeTimer?.cancel();

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
    autoMatchCooldown.value = 0;
    revealCooldown.value = 0;
    slowTimeCooldown.value = 0;
    highlightCooldown.value = 0;
    slowTimeSeconds.value = 0;
    wrongAttempts.value = 0;
    lastReward.value = null;
    _lastMatchTime = null;
    _firstSelectedCard = null;
    _isProcessing = false;
    _timerTicks = 0;
    _wrongAttemptsThisGame = 0;
    _consecutiveWrongForSound = 0;

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
    int totalCards = level.value.totalCards;
    int pairsNeeded = level.value.pairsCount;

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

  Future<void> usePowerUp(PowerUpType type) async {
    if (!canUsePowerUp(type)) return;

    final wasConsumed = await progression.consumePowerUp(type);
    if (!wasConsumed) return;

    switch (type) {
      case PowerUpType.reveal:
        await _useRevealPowerUp();
      case PowerUpType.autoMatch:
        await _useAutoMatchPowerUp();
      case PowerUpType.slowTime:
        _useSlowTimePowerUp();
      case PowerUpType.highlight:
        await _useHighlightPowerUp();
    }
  }

  Future<void> _useRevealPowerUp() async {
    _startCooldown(
      revealCooldown,
      (timer) => _revealCooldownTimer = timer,
      seconds: _powerUpCooldownSeconds,
    );
    _firstSelectedCard = null;
    _isProcessing = true;
    state.value = GameState.preview;
    SoundService.playFlip();

    for (final card in cards) {
      if (!card.isMatched.value) {
        card.isFlipped.value = true;
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    for (final card in cards) {
      if (!card.isMatched.value) {
        card.isFlipped.value = false;
      }
    }

    _isProcessing = false;
    state.value = GameState.playing;
  }

  Future<void> _useAutoMatchPowerUp() async {
    final pair = _findUnmatchedPair();
    if (pair == null) return;

    _startCooldown(
      autoMatchCooldown,
      (timer) => _autoMatchCooldownTimer = timer,
      seconds: _powerUpCooldownSeconds,
    );
    _firstSelectedCard = null;
    _isProcessing = true;
    moves.value++;

    final first = pair.$1;
    final second = pair.$2;
    first.isHighlighted.value = false;
    second.isHighlighted.value = false;
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

  void _useSlowTimePowerUp() {
    _startCooldown(
      slowTimeCooldown,
      (timer) => _slowTimeCooldownTimer = timer,
      seconds: _powerUpCooldownSeconds,
    );
    slowTimeSeconds.value = _slowTimeDurationSeconds;
    _slowTimeTimer?.cancel();
    _slowTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (slowTimeSeconds.value <= 1 ||
          state.value == GameState.finished ||
          state.value == GameState.lost) {
        slowTimeSeconds.value = 0;
        timer.cancel();
      } else if (state.value == GameState.playing) {
        slowTimeSeconds.value--;
      }
    });
  }

  Future<void> _useHighlightPowerUp() async {
    final pair = _findUnmatchedPair();
    if (pair == null) return;

    _startCooldown(
      highlightCooldown,
      (timer) => _highlightCooldownTimer = timer,
      seconds: _powerUpCooldownSeconds,
    );
    pair.$1.isHighlighted.value = true;
    pair.$2.isHighlighted.value = true;
    SoundService.playFlip();

    await Future.delayed(const Duration(seconds: 2));

    pair.$1.isHighlighted.value = false;
    pair.$2.isHighlighted.value = false;
  }

  void _compareCards(CardModel secondCard) async {
    _isProcessing = true;
    moves.value++;
    if (_firstSelectedCard!.value == secondCard.value) {
      // Match!
      _firstSelectedCard!.isMatched.value = true;
      secondCard.isMatched.value = true;
      matchesFound.value++;

      wrongAttempts.value = 0;
      _wrongAttemptsThisGame = 0;
      _consecutiveWrongForSound = 0;

      _handleMatch();
      SoundService.playMatch();

      _firstSelectedCard = null;
      _isProcessing = false;

      _checkWin();
    }
    // if (_firstSelectedCard!.value == secondCard.value) {
    //   // Match!
    //   _firstSelectedCard!.isMatched.value = true;
    //   secondCard.isMatched.value = true;
    //   matchesFound.value++;
    //   wrongAttempts.value = 0;
    //   _handleMatch();
    //   SoundService.playMatch();
    //   _firstSelectedCard = null;
    //   _isProcessing = false;
    //   _checkWin();
    // }
    else {
      // No match
      state.value = GameState.comparing;
      _firstSelectedCard!.isWrong.value = true;
      secondCard.isWrong.value = true;
      combo.value = 1; // Reset combo on mismatch

      wrongAttempts.value++;
      _wrongAttemptsThisGame++;
      _consecutiveWrongForSound++;

      // ❤️ Lose a heart every 2 cumulative wrong attempts
      if (_wrongAttemptsThisGame.isEven) {
        final isOutOfHearts = await progression.loseHeart();
        if (isOutOfHearts) {
          await Future.delayed(const Duration(milliseconds: 300));
          _firstSelectedCard!.isFlipped.value = false;
          secondCard.isFlipped.value = false;
          _firstSelectedCard!.isWrong.value = false;
          secondCard.isWrong.value = false;
          _firstSelectedCard = null;
          _loseGame();
          return;
        }
      }

      // 🔊 Play fail sound ONLY at exactly 3 consecutive wrong attempts
      if (_consecutiveWrongForSound == 3) {
        SoundService.playFail();
        _consecutiveWrongForSound = 0;
      }

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
          _timerTicks++;
          if (slowTimeSeconds.value > 0 && _timerTicks.isOdd) {
            return;
          }

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

  void _startCooldown(
    RxInt target,
    void Function(Timer timer) storeTimer, {
    int seconds = _powerUpCooldownSeconds,
  }) {
    target.value = seconds;
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

  RxInt _cooldownFor(PowerUpType type) {
    return switch (type) {
      PowerUpType.reveal => revealCooldown,
      PowerUpType.autoMatch => autoMatchCooldown,
      PowerUpType.slowTime => slowTimeCooldown,
      PowerUpType.highlight => highlightCooldown,
    };
  }

  void _checkWin() {
    if (matchesFound.value == level.value.pairsCount) {
      _winGame();
    }
  }

  void _handleMatch() {
    wrongAttempts.value = 0;

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

  void _winGame() async {
    _isProcessing = true;
    // Add bonus for finishing fast
    final elapsed = isTimeAttack
        ? level.value.timeLimit - remainingSeconds.value
        : secondsElapsed.value;
    int timeBonus = (300 - elapsed).clamp(0, 1000);
    score.value += timeBonus;

    lastReward.value = await progression.recordWin(
      level: level.value,
      mode: mode.value,
      score: score.value,
      moves: moves.value,
      elapsedSeconds: elapsed,
      wrongAttempts: _wrongAttemptsThisGame,
    );

    SoundService.playWin();

    state.value = GameState.finished;
    _timer?.cancel();
  }

  void _loseGame() {
    state.value = GameState.lost;
    progression.recordLoss();
    _timer?.cancel();
    _isProcessing = false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    _autoMatchCooldownTimer?.cancel();
    _revealCooldownTimer?.cancel();
    _slowTimeCooldownTimer?.cancel();
    _highlightCooldownTimer?.cancel();
    _slowTimeTimer?.cancel();
    SoundService.dispose();
    super.onClose();
  }
}
