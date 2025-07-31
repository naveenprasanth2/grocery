import 'package:flutter/material.dart';
import '../../domain/entities/checklist_item.dart';
import 'package:intl/intl.dart';

class UKChecklistItemsList extends StatelessWidget {
  final List<ChecklistItem> items;
  final Function(String) onToggleItem;
  final Function(String) onDeleteItem;
  final Function(ChecklistItem) onEditItem;
  final AnimationController listAnimationController;

  const UKChecklistItemsList({
    super.key,
    required this.items,
    required this.onToggleItem,
    required this.onDeleteItem,
    required this.onEditItem,
    required this.listAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: listAnimationController,
            curve: Interval(
              index / (items.length + 1),
              (index + 1) / (items.length + 1),
              curve: Curves.easeOut,
            ),
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.5, 0),
              end: Offset.zero,
            ).animate(animation),
            child: Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text(
                        "Are you sure you want to delete this item?",
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("CANCEL"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("DELETE"),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                onDeleteItem(item.id);
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Checkbox(
                    value: item.type == ItemType.task
                        ? item.isChecked
                        : item.isBought,
                    onChanged: (_) {
                      onToggleItem(item.id);
                    },
                  ),
                  title: Row(
                    children: [
                      if (item.type == ItemType.product)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '£${item.totalCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            decoration:
                                (item.type == ItemType.task &&
                                        item.isChecked) ||
                                    (item.type == ItemType.product &&
                                        item.isBought)
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: item.isPriority
                                ? FontWeight.bold
                                : null,
                            color:
                                (item.type == ItemType.task &&
                                        item.isChecked) ||
                                    (item.type == ItemType.product &&
                                        item.isBought)
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${item.type == ItemType.task ? 'Task' : 'Product'} • ${item.category}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          if (item.type == ItemType.product &&
                              item.quantity > 1)
                            Text(
                              ' • Qty: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                        ],
                      ),
                      if (item.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Due: ${DateFormat('MMM d, yyyy').format(item.dueDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDueDateColor(item.dueDate!, context),
                              fontWeight: _isOverdue(item.dueDate!)
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        ),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.notes!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isPriority)
                        const Icon(
                          Icons.priority_high,
                          color: Colors.amber,
                          size: 20,
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEditItem(item),
                        visualDensity: VisualDensity.compact,
                        iconSize: 20,
                      ),
                    ],
                  ),
                  isThreeLine:
                      item.notes != null && item.notes!.isNotEmpty ||
                      item.dueDate != null,
                  onTap: () {
                    // Show details or quick edit
                    onEditItem(item);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  Color _getDueDateColor(DateTime dueDate, BuildContext context) {
    if (_isOverdue(dueDate)) {
      return Colors.red;
    }

    // Due within 7 days
    if (dueDate.difference(DateTime.now()).inDays < 7) {
      return Colors.orange;
    }

    return Theme.of(context).colorScheme.secondary;
  }
}
