import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final bool showOnlyUnchecked;
  final Function(String) onCategoryChanged;
  final VoidCallback onToggleUnchecked;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.showOnlyUnchecked,
    required this.onCategoryChanged,
    required this.onToggleUnchecked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.categoryIcons.keys.length,
              itemBuilder: (context, index) {
                final category = AppConstants.categoryIcons.keys.elementAt(index);
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppConstants.categoryIcons[category],
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(category),
                      ],
                    ),
                    onSelected: (selected) {
                      onCategoryChanged(selected ? category : 'All');
                    },
                    selectedColor: Colors.green.shade600,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: showOnlyUnchecked
                  ? Colors.orange.shade600
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.checklist_rtl,
                color: showOnlyUnchecked ? Colors.white : Colors.grey.shade600,
              ),
              onPressed: onToggleUnchecked,
              tooltip: 'Show only pending items',
            ),
          ),
        ],
      ),
    );
  }
}
