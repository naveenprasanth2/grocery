import 'package:flutter/material.dart';

class UKChecklistEmptyState extends StatelessWidget {
  final bool isSearching;
  final bool isFiltering;
  final VoidCallback onAddNewItem;

  const UKChecklistEmptyState({
    super.key,
    required this.isSearching,
    required this.isFiltering,
    required this.onAddNewItem,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    IconData iconData;

    if (isSearching) {
      message = 'No tasks match your search';
      iconData = Icons.search_off;
    } else if (isFiltering) {
      message = 'No tasks match your filter';
      iconData = Icons.filter_list_off;
    } else {
      message = 'No tasks yet. Add your first task to get started!';
      iconData = Icons.playlist_add_check;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (!isSearching && !isFiltering)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ElevatedButton.icon(
                onPressed: onAddNewItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Task'),
              ),
            ),
        ],
      ),
    );
  }
}
