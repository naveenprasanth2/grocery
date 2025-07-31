import 'package:flutter/material.dart';
import 'package:grocery/features/grocery_list/data/services/grocery_storage_service.dart';
import 'package:grocery/features/grocery_list/domain/entities/grocery_history.dart';

class HistoryDialog extends StatefulWidget {
  const HistoryDialog({super.key});

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<HistoryDialog> {
  late Future<List<GroceryHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = GroceryStorageService.instance.loadHistory();
  }

  void _deleteHistory(String id) async {
    await GroceryStorageService.instance.deleteHistory(id);
    setState(_loadHistory);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Shopping History'),
      content: SizedBox(
        width: 350,
        child: FutureBuilder<List<GroceryHistory>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No history yet.');
            }
            final history = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final entry = history[index];
                return ListTile(
                  title: Text(entry.name),
                  subtitle: Text(
                    '${entry.date.toLocal().toString().split(' ')[0]}\n${entry.items.join(', ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteHistory(entry.id),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
