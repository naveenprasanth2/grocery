import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:grocery/core/constants/app_constants.dart';

class ShoppingTimerDialog extends StatefulWidget {
  const ShoppingTimerDialog({super.key});

  @override
  State<ShoppingTimerDialog> createState() => _ShoppingTimerDialogState();
}

class _ShoppingTimerDialogState extends State<ShoppingTimerDialog> {
  Duration _duration = const Duration(minutes: 45);
  Duration _remaining = const Duration(minutes: 45);
  Timer? _timer;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remaining.inSeconds == 0) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining -= const Duration(seconds: 1));
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
        _playAlarm();
        _showAlarmDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remaining = _duration;
      _isRunning = false;
    });
  }

  void _setDuration(Duration newDuration) {
    _timer?.cancel();
    setState(() {
      _duration = newDuration;
      _remaining = newDuration;
      _isRunning = false;
    });
  }

  Future<void> _playAlarm() async {
    await _audioPlayer.play(AssetSource('alarm.mp3'));
  }

  void _showAlarmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.alarm, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Time is up!'),
          ],
        ),
        content: const Text('Shopping time is over!'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            onPressed: () {
              _audioPlayer.stop();
              Navigator.pop(context);
            },
            child: const Text(
              'Stop Alarm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours > 0 ? '${d.inHours}:' : '';
    return '$h$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      title: Row(
        children: [
          Icon(Icons.timer, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          const Text('Shopping Timer'),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 60, color: Colors.orange.shade600),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_remaining),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Shopping time',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),

                  onPressed: _isRunning || _duration.inMinutes <= 5
                      ? null
                      : () => _setDuration(
                          _duration - const Duration(minutes: 5),
                        ),
                ),
                Text('${_duration.inMinutes} min'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _isRunning
                      ? null
                      : () => _setDuration(
                          _duration + const Duration(minutes: 5),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _pauseTimer();
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
        if (!_isRunning)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            onPressed: _startTimer,
            child: const Text('Start', style: TextStyle(color: Colors.white)),
          ),
        if (_isRunning)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            onPressed: _pauseTimer,
            child: const Text('Pause', style: TextStyle(color: Colors.white)),
          ),
        TextButton(onPressed: _resetTimer, child: const Text('Reset')),
      ],
    );
  }
}
