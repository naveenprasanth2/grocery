import 'package:flutter/material.dart';
import 'package:grocery/models/models.dart';
import 'package:grocery/provider/checklist_provider.dart';
import 'package:grocery/provider/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: Colors.purple.shade700, size: 28),
            SizedBox(width: 10),
            Text(
              'Shopping History',
              style: TextStyle(
                color: Colors.purple.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return _buildHistoryList(context, expenseProvider);
        },
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, ExpenseProvider provider) {
    if (provider.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No shopping history yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete your first shopping list to see history!',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: provider.history.length,
        itemBuilder: (context, index) {
          final history = provider.history[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Icon(Icons.shopping_bag, color: Colors.purple.shade600),
              ),
              title: Text(
                history.storeName.isNotEmpty
                    ? history.storeName
                    : 'Shopping Trip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(history.date),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${history.items.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '• Total: \$${history.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'restore',
                    child: Row(
                      children: [
                        Icon(Icons.restore, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Restore List'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'restore') {
                    _restoreShoppingList(context, history);
                  } else if (value == 'delete') {
                    _showDeleteHistoryDialog(context, history);
                  }
                },
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...history.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                item.isChecked
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: item.isChecked
                                    ? Colors.green
                                    : Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    decoration: item.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: item.isChecked
                                        ? Colors.grey.shade500
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (item.price > 0)
                                Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple.shade600,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _restoreShoppingList(BuildContext context, ShoppingHistory history) {
    final checkboxModel = context.read<CheckBoxModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.green.shade600),
            SizedBox(width: 8),
            Text('Restore Shopping List'),
          ],
        ),
        content: Text(
          'This will replace your current shopping list with the items from this history. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Clear current list
              while (checkboxModel.items.isNotEmpty) {
                checkboxModel.deleteItem(0);
              }

              // Add items from history
              for (final item in history.items) {
                checkboxModel.addItem(
                  item.title,
                  price: item.price,
                  quantity: item.quantity,
                );
              }

              Navigator.pop(context);
              Navigator.pop(context); // Go back to main screen

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shopping list restored!'),
                  backgroundColor: Colors.green.shade600,
                ),
              );
            },
            child: Text('Restore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteHistoryDialog(BuildContext context, ShoppingHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade600),
            SizedBox(width: 8),
            Text('Delete History'),
          ],
        ),
        content: Text('Are you sure you want to delete this shopping history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<ExpenseProvider>().deleteHistory(history.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
