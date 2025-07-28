import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/grocery_utils.dart';
import '../providers/grocery_list_provider.dart';
import '../../domain/entities/grocery_item.dart';

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
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredItems.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;

              // Find actual indices in the full list
              final oldItem = filteredItems[oldIndex];
              final newItem = filteredItems[newIndex];
              final actualOldIndex = provider.items.indexOf(oldItem);
              final actualNewIndex = provider.items.indexOf(newItem);

              provider.moveItem(actualOldIndex, actualNewIndex);
            },
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final category = CategoryUtils.categorizeItem(item.title);

              return SlideTransition(
                key: ValueKey('slide_${item.id}_$index'),
                position:
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animationController,
                        curve: Interval(
                          index * 0.1,
                          1.0,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                    ),
                child: Card(
                  key: ValueKey('card_${item.id}_$index'),
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
                    child: Row(
                      children: [
                        // Reorder handle
                        ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 16,
                            ),
                            child: Icon(
                              Icons.drag_handle,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        // Main list tile content
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
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
                                      color: CategoryUtils.getCategoryColor(
                                        category,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: item.price > 0 || item.quantity > 1
                                ? Text(
                                    'Qty: ${item.quantity}${item.price > 0 ? ' • \$${item.price.toStringAsFixed(2)}' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit button
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _showEditDialog(context, provider, item),
                                  tooltip: 'Edit item',
                                ),
                                // Checkbox
                                Checkbox(
                                  value: item.isChecked,
                                  activeColor: Colors.green.shade600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      final actualIndex = provider.items
                                          .indexOf(item);
                                      provider.toggle(actualIndex, value);

                                      if (value) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                            backgroundColor:
                                                Colors.green.shade600,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            onLongPress: () =>
                                _showDeleteDialog(context, provider, item),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    GroceryListProvider provider,
    GroceryItem item,
  ) {
    final editNameController = TextEditingController(text: item.title);
    final editQuantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final editPriceController = TextEditingController(
      text: item.price > 0 ? item.price.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width * 0.85;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Edit Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editNameController,
                  decoration: InputDecoration(
                    labelText: 'Item name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.shopping_basket_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: editQuantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: editPriceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                ),
              ),
              onPressed: () {
                if (editNameController.text.trim().isNotEmpty) {
                  final index = provider.items.indexOf(item);
                  final newPrice =
                      double.tryParse(editPriceController.text.trim()) ?? 0.0;
                  final newQuantity =
                      int.tryParse(editQuantityController.text.trim()) ?? 1;

                  provider.updateItem(
                    index,
                    editNameController.text.trim(),
                    price: newPrice,
                    quantity: newQuantity,
                  );
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Item updated successfully!'),
                        ],
                      ),
                      backgroundColor: Colors.blue.shade600,
                    ),
                  );
                }
              },
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    GroceryListProvider provider,
    GroceryItem item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
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
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      // Add item back - could be enhanced with actual undo functionality
                      provider.addItem(
                        item.title,
                        price: item.price,
                        quantity: item.quantity,
                      );
                    },
                  ),
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
