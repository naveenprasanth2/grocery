import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/grocery_utils.dart';
import '../providers/grocery_list_provider.dart';

class GroceryItemsList extends StatelessWidget {
  final String searchQuery;
  final String categoryFilter;
  final bool showOnlyUnchecked;
  final AnimationController animationController;

  const GroceryItemsList({
    super.key,
    required this.searchQuery,
    required this.categoryFilter,
    required this.showOnlyUnchecked,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryListProvider>(
      builder: (context, provider, child) {
        final filteredItems = provider.getFilteredItems(
          searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
          categoryFilter: categoryFilter,
          showOnlyUnchecked: showOnlyUnchecked,
        );

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final category = CategoryUtils.categorizeItem(item.title);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        item.isChecked ? Colors.green.shade50 : Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: item.isChecked
                          ? Colors.green.shade200
                          : CategoryUtils.getCategoryColor(category),
                      child: Icon(
                        CategoryUtils.getCategoryIcon(category),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              decoration: item.isChecked
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isChecked
                                  ? Colors.grey.shade500
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CategoryUtils.getCategoryColor(
                              category,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: CategoryUtils.getCategoryColor(category),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Checkbox(
                      value: item.isChecked,
                      activeColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onChanged: (bool? value) {
                        if (value != null) {
                          final actualIndex = provider.items.indexOf(item);
                          provider.toggle(actualIndex, value);

                          if (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '✓ ${GroceryUtils.extractItemName(item.title)} completed!',
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Colors.green.shade600,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    onLongPress: () =>
                        _showDeleteDialog(context, provider, item),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    GroceryListProvider provider,
    item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Delete Item'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${GroceryUtils.extractItemName(item.title)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
              final index = provider.items.indexOf(item);
              provider.deleteItem(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${GroceryUtils.extractItemName(item.title)} deleted',
                  ),
                  backgroundColor: Colors.red.shade600,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
