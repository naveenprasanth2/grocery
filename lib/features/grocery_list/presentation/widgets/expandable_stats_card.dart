import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/grocery_list_provider.dart';

class ExpandableStatsCard extends StatefulWidget {
  final GroceryListProvider groceryProvider;

  const ExpandableStatsCard({super.key, required this.groceryProvider});

  @override
  State<ExpandableStatsCard> createState() => _ExpandableStatsCardState();
}

class _ExpandableStatsCardState extends State<ExpandableStatsCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedItems = widget.groceryProvider.completedCount;
    final totalItems = widget.groceryProvider.count;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return AnimatedContainer(
      duration: AppConstants.shortAnimationDuration,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Card(
        color: AppConstants.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Column(
          children: [
            // Compact header
            InkWell(
              onTap: _toggleExpansion,
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Progress circle
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress < 0.5 ? Colors.orange : Colors.green,
                        ),
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Main stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$completedItems / $totalItems items',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: \$${widget.groceryProvider.totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expand icon
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: AppConstants.mediumAnimationDuration,
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expandable content
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 12),
                    // Detailed stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDetailedStatChip(
                          icon: Icons.list_alt,
                          label: 'Total Items',
                          value: '$totalItems',
                          color: Colors.blue,
                        ),
                        _buildDetailedStatChip(
                          icon: Icons.shopping_cart,
                          label: 'Remaining',
                          value: '${widget.groceryProvider.remainingCount}',
                          color: Colors.orange,
                        ),
                        _buildDetailedStatChip(
                          icon: Icons.check_circle,
                          label: 'Completed',
                          value: '$completedItems',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Cost breakdown
                    _buildCostBreakdown(),
                    const SizedBox(height: 16),
                    // Progress bar
                    _buildProgressBar(progress),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatChip({
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCostItem(
          'Total Cost',
          widget.groceryProvider.totalCost,
          Colors.purple,
        ),
        _buildCostItem(
          'Completed',
          widget.groceryProvider.completedCost,
          Colors.green,
        ),
        _buildCostItem(
          'Remaining',
          widget.groceryProvider.remainingCost,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildCostItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Shopping Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: progress < 0.5 ? Colors.orange : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress < 0.5 ? Colors.orange : Colors.green,
          ),
          minHeight: 8,
        ),
      ],
    );
  }
}
