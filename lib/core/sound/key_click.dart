import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Soft key-press click (iPhone-style) for fare / keypad typing.
class KeyClick {
  KeyClick._();

  static const _asset = 'sounds/key_click.wav';
  static const _volume = 0.55;

  /// Small pool so rapid taps can overlap like a real keyboard.
  static final List<AudioPlayer> _pool = List.generate(
    3,
    (_) => AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..setPlayerMode(PlayerMode.lowLatency),
  );
  static int _next = 0;
  static bool _warmed = false;

  static Future<void> warmUp() async {
    if (_warmed) return;
    try {
      for (final p in _pool) {
        await p.setSource(AssetSource(_asset));
        await p.setVolume(_volume);
      }
      _warmed = true;
    } catch (_) {
      _warmed = false;
    }
  }

  static Future<void> play() async {
    HapticFeedback.selectionClick();
    try {
      if (!_warmed) await warmUp();
      final p = _pool[_next++ % _pool.length];
      await p.seek(Duration.zero);
      await p.resume();
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
