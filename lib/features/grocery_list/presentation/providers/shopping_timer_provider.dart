import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

typedef AlarmCallback = void Function();

class ShoppingTimerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AlarmCallback? onAlarm;
  Duration _duration = const Duration(minutes: 45);
  Duration _remaining = const Duration(minutes: 45);
  Timer? _timer;
  bool _isRunning = false;

  Duration get duration => _duration;
  Duration get remaining => _remaining;
  bool get isRunning => _isRunning;

  void setDuration(Duration newDuration) {
    if (_isRunning) return;
    _duration = newDuration;
    _remaining = newDuration;
    notifyListeners();
  }

  void start() {
    if (_isRunning || _remaining.inSeconds == 0) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        _remaining -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        timer.cancel();
        _isRunning = false;
        _onTimerComplete();
        if (onAlarm != null) onAlarm!();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> _onTimerComplete() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 500, 500, 500, 500, 500, 500, 500], repeat: 0);
    }
    await _audioPlayer.play(AssetSource('alarm.mp3'));
  }

  bool get alarmActive => !_isRunning && _remaining.inSeconds == 0;

  Future<void> stopAlarm() async {
    await _audioPlayer.stop();
    if (await Vibration.hasVibrator()) {
      Vibration.cancel();
    }
    notifyListeners();
  }

  void pause() {
    _isRunning = false;
    notifyListeners();
  }

  void reset() {
    _remaining = _duration;
    _isRunning = false;
    _timer?.cancel();
    _audioPlayer.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
