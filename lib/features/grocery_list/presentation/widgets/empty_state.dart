import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class EmptyState extends StatelessWidget {
  final Function(String) onQuickAdd;

  const EmptyState({
    super.key,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your grocery list is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first item to get started!',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: AppConstants.grocerySuggestions.take(3).map((suggestion) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  label: Text(suggestion),
                  onPressed: () => onQuickAdd(suggestion),
                  backgroundColor: Colors.green.shade50,
                  labelStyle: TextStyle(color: Colors.green.shade700),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
