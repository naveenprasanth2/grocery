import 'package:flutter/material.dart';

/// A comprehensive stats card showing task completion and expense tracking
class UKChecklistStatsCard extends StatelessWidget {
  final int totalItems;
  final int completedTasks;
  final int purchasedProducts;
  final int remainingTasks;
  final int remainingProducts;
  final double completionPercentage;
  final double totalBudget;
  final double spentAmount;
  final double remainingBudget;

  const UKChecklistStatsCard({
    super.key,
    required this.totalItems,
    required this.completedTasks,
    required this.purchasedProducts,
    required this.remainingTasks,
    required this.remainingProducts,
    required this.completionPercentage,
    required this.totalBudget,
    required this.spentAmount,
    required this.remainingBudget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = (remainingTasks + remainingProducts) == 0 && totalItems > 0;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          children: [
            // Progress Overview
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
                        'Tasks: $completedTasks completed, $remainingTasks remaining',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Products: $purchasedProducts bought, $remainingProducts pending',
                        style: const TextStyle(fontSize: 12),
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

            // Financial Overview
            if (totalBudget > 0) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Expense Tracking',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Budget: £${totalBudget.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Spent: £${spentAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: spentAmount > totalBudget
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      Text(
                        'Remaining: £${remainingBudget.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: remainingBudget < 0
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: spentAmount > totalBudget
                          ? Colors.red.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        totalBudget > 0
                            ? '${(spentAmount / totalBudget * 100).toStringAsFixed(0)}%'
                            : '0%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: spentAmount > totalBudget
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalBudget > 0
                    ? (spentAmount / totalBudget).clamp(0.0, 1.0)
                    : 0,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  spentAmount > totalBudget ? Colors.red : Colors.green,
                ),
                minHeight: 4,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
