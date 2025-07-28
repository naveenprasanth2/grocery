import 'dart:async';
import 'package:flutter/material.dart';

class ShoppingTimerProvider extends ChangeNotifier {
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
        notifyListeners();
      }
    });
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
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
