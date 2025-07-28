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
            child: const Text('Start', style: TextStyle(color: Colors.white)),
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
            child: const Text('Pause', style: TextStyle(color: Colors.white)),
          ),
        TextButton(onPressed: timer.reset, child: const Text('Reset')),
      ],
    );
  }
}
