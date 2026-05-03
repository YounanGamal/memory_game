import 'dart:async';
import 'package:get/get.dart';
import '../core/enums/game_enums.dart';
import '../core/services/sound_service.dart';
import '../models/card_model.dart';

class GameController extends GetxController {
  final Rx<GameState> state = GameState.idle.obs;
  final Rx<GameLevel> level = GameLevel.easy.obs;

  final RxList<CardModel> cards = <CardModel>[].obs;
  final RxInt moves = 0.obs;
  final RxInt secondsElapsed = 0.obs;
  final RxInt matchesFound = 0.obs;
  final RxInt score = 0.obs;
  final RxInt combo = 1.obs;
  final RxInt bestCombo = 1.obs;

  DateTime? _lastMatchTime;
  Timer? _timer;
  CardModel? _firstSelectedCard;
  bool _isProcessing = false;

  static const int _comboThresholdSeconds = 5;

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

  void startGame(GameLevel selectedLevel) async {
    level.value = selectedLevel;
    _generateBoard();
    moves.value = 0;
    secondsElapsed.value = 0;
    matchesFound.value = 0;
    score.value = 0;
    combo.value = 1;
    bestCombo.value = 1;
    _lastMatchTime = null;
    _firstSelectedCard = null;
    _isProcessing = false;

    // Start Preview
    state.value = GameState.preview;
    for (var card in cards) {
      card.isFlipped.value = true;
    }

    await Future.delayed(Duration(seconds: level.value.previewDuration));

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

      if (matchesFound.value ==
          (level.value.gridSize * level.value.gridSize) ~/ 2) {
        _winGame();
      }
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
        secondsElapsed.value++;
      } else if (state.value == GameState.finished) {
        timer.cancel();
      }
    });
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
    int timeBonus = (300 - secondsElapsed.value).clamp(0, 1000);
    score.value += timeBonus;

    SoundService.playWin();

    state.value = GameState.finished;
    _timer?.cancel();
  }

  @override
  void onClose() {
    _timer?.cancel();
    SoundService.dispose();
    super.onClose();
  }
}
