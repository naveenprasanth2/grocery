import 'package:flutter/material.dart';

/// A simplified stats card that doesn't rely on the percent_indicator package
class UKChecklistStatsCard extends StatelessWidget {
  final int totalItems;
  final int completedItems;
  final int remainingItems;
  final double completionPercentage;

  const UKChecklistStatsCard({
    super.key,
    required this.totalItems,
    required this.completedItems,
    required this.remainingItems,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = completedItems == totalItems && totalItems > 0;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'UK Moving Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isDone)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed: $completedItems of $totalItems tasks',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Remaining: $remainingItems tasks',
                        style: TextStyle(
                          fontSize: 14,
                          color: remainingItems > 0
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? Colors.green.withOpacity(0.2)
                        : theme.primaryColor.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      '${completionPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: isDone ? Colors.green : theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? Colors.green : theme.primaryColor,
              ),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}
