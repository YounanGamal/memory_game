import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final Map<String, AudioPlayer> _players = {};

  static Future<void> _play(String file, double volume) async {
    try {
      final player = _players.putIfAbsent(file, AudioPlayer.new);
      await player.stop();
      await player.play(AssetSource('sound/$file'), volume: volume);
    } catch (e) {
      debugPrint('Sound error while playing $file: $e');
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> playFlip() async {
    await _play('click.mp3', 0.5);
    HapticFeedback.selectionClick();
  }

  static Future<void> playMatch() async {
    await _play('success.mp3', 0.7);
    HapticFeedback.mediumImpact();
  }

  static Future<void> playWrong() async {
    await _play('fail.mp3', 0.6);
    HapticFeedback.heavyImpact();
  }

  static Future<void> playWin() async {
    await _play('win.mp3', 1.0);
    HapticFeedback.vibrate();
  }

  static Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
