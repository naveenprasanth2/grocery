import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/grocery_list_provider.dart';

class StatsCards extends StatelessWidget {
  final GroceryListProvider groceryProvider;

  const StatsCards({super.key, required this.groceryProvider});

  @override
  Widget build(BuildContext context) {
    final completedItems = groceryProvider.completedCount;
    final totalItems = groceryProvider.count;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return AnimatedContainer(
      duration: AppConstants.shortAnimationDuration,
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20),
      child: Card(
        color: AppConstants.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatChip(
                    icon: Icons.list_alt,
                    label: 'Total',
                    value: '$totalItems',
                    color: Colors.blue,
                  ),
                  _buildStatChip(
                    icon: Icons.shopping_cart,
                    label: 'Remaining',
                    value: '${groceryProvider.remainingCount}',
                    color: Colors.orange,
                  ),
                  _buildStatChip(
                    icon: Icons.attach_money,
                    label: 'Total Cost',
                    value: '\$${groceryProvider.totalCost.toStringAsFixed(2)}',
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Progress',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade600,
                ),
                minHeight: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
