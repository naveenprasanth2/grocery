import 'package:flutter/material.dart';

class UKChecklistAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleShowUnchecked;
  final bool showOnlyUnchecked;
  final VoidCallback onToggleShowPriority;
  final bool showOnlyPriority;
  final int listSize;

  const UKChecklistAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onToggleSearch,
    required this.onToggleShowUnchecked,
    required this.showOnlyUnchecked,
    required this.onToggleShowPriority,
    required this.showOnlyPriority,
    required this.listSize,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? const Text('Search Items')
          : const Text('UK Moving Checklist'),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          tooltip: isSearching ? 'Close Search' : 'Search',
          onPressed: onToggleSearch,
        ),
        IconButton(
          icon: Icon(
            showOnlyUnchecked ? Icons.check_box_outline_blank : Icons.check_box,
          ),
          tooltip: showOnlyUnchecked
              ? 'Show All Tasks'
              : 'Show Incomplete Tasks',
          onPressed: onToggleShowUnchecked,
        ),
        IconButton(
          icon: Icon(
            showOnlyPriority ? Icons.priority_high : Icons.low_priority,
            color: showOnlyPriority ? Colors.amber : null,
          ),
          tooltip: showOnlyPriority ? 'Show All Tasks' : 'Show Priority Tasks',
          onPressed: onToggleShowPriority,
        ),
        if (!isSearching && listSize > 0)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Text(
                '$listSize',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
