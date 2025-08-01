import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery/core/constants/app_constants.dart';
import '../../providers/shopping_timer_provider.dart';

class ShoppingTimerDialog extends StatelessWidget {
  const ShoppingTimerDialog({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours > 0 ? '${d.inHours}:' : '';
    return '$h$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<ShoppingTimerProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (timer.alarmActive) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.largeBorderRadius,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.alarm, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text('Time is up!'),
              ],
            ),
            content: const Text('Shopping timer completed.'),
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
                  timer.stopAlarm();
                  Navigator.of(ctx).pop();
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
    });
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
              _formatDuration(timer.remaining),
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
                  onPressed: timer.isRunning || timer.duration.inMinutes <= 5
                      ? null
                      : () => timer.setDuration(
                          timer.duration - const Duration(minutes: 5),
                        ),
                ),
                Text('${timer.duration.inMinutes} min'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: timer.isRunning
                      ? null
                      : () => timer.setDuration(
                          timer.duration + const Duration(minutes: 5),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            if (!timer.isRunning)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                ),
                onPressed: timer.start,
                child: const Text(
                  'Start',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (timer.isRunning)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                ),
                onPressed: timer.pause,
                child: const Text(
                  'Pause',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            TextButton(onPressed: timer.reset, child: const Text('Reset')),
          ],
        ),
      ],
    );
  }
}
