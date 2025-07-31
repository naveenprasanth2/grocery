import 'package:flutter/material.dart';
import 'package:grocery/features/grocery_list/domain/entities/grocery_history.dart';
import 'package:uuid/uuid.dart';

class SaveToHistoryDialog extends StatefulWidget {
  final List<String> items;
  const SaveToHistoryDialog({super.key, required this.items});

  @override
  State<SaveToHistoryDialog> createState() => _SaveToHistoryDialogState();
}

class _SaveToHistoryDialogState extends State<SaveToHistoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save to History'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'List Name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 12),
            Text('Items: ${widget.items.join(', ')}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(
                GroceryHistory(
                  id: const Uuid().v4(),
                  name: _nameController.text.trim(),
                  date: DateTime.now(),
                  items: widget.items,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
