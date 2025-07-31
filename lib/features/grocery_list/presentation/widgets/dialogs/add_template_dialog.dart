import 'package:flutter/material.dart';
import 'package:grocery/features/grocery_list/domain/entities/grocery_template.dart';
import 'package:uuid/uuid.dart';

class AddTemplateDialog extends StatefulWidget {
  const AddTemplateDialog({super.key});

  @override
  State<AddTemplateDialog> createState() => _AddTemplateDialogState();
}

class _AddTemplateDialogState extends State<AddTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<GroceryTemplateItem> _items = [];
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');

  void _addItem() {
    if (_itemController.text.trim().isEmpty) return;
    setState(() {
      _items.add(
        GroceryTemplateItem(
          title: _itemController.text.trim(),
          quantity: int.tryParse(_qtyController.text) ?? 1,
        ),
      );
      _itemController.clear();
      _qtyController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Template'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Template Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itemController,
                      decoration: const InputDecoration(labelText: 'Item'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(labelText: 'Qty'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addItem),
                ],
              ),
              const SizedBox(height: 8),
              if (_items.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, idx) {
                      final item = _items[idx];
                      return ListTile(
                        dense: true,
                        title: Text(item.title),
                        trailing: Text('x${item.quantity}'),
                        leading: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _items.removeAt(idx);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _items.isNotEmpty) {
              Navigator.of(context).pop(
                GroceryTemplate(
                  id: const Uuid().v4(),
                  name: _nameController.text.trim(),
                  items: List.from(_items),
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
