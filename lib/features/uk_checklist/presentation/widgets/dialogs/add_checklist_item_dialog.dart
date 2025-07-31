import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/uk_checklist_provider.dart';
import 'package:provider/provider.dart';

class AddChecklistItemDialog extends StatefulWidget {
  final Function(String, String, String?, DateTime?, bool) onItemAdded;

  const AddChecklistItemDialog({super.key, required this.onItemAdded});

  @override
  State<AddChecklistItemDialog> createState() => _AddChecklistItemDialogState();
}

class _AddChecklistItemDialogState extends State<AddChecklistItemDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = '';
  DateTime? _selectedDueDate;
  bool _isPriority = false;

  @override
  void initState() {
    super.initState();
    // Initialize with first category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = Provider.of<UKChecklistProvider>(
        context,
        listen: false,
      ).categories;
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categories.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<UKChecklistProvider>(context).categories;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Task',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task',
                border: OutlineInputBorder(),
                hintText: 'Enter task name',
              ),
              maxLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: categories.isNotEmpty && _selectedCategory.isEmpty
                  ? categories.first
                  : (_selectedCategory.isEmpty ? null : _selectedCategory),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Add any additional notes',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date (Optional)',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDueDate != null
                          ? DateFormat('dd MMM yyyy').format(_selectedDueDate!)
                          : 'Select a date',
                      style: TextStyle(
                        color: _selectedDueDate != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            CheckboxListTile(
              title: const Text('Mark as Priority'),
              value: _isPriority,
              onChanged: (bool? value) {
                setState(() {
                  _isPriority = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a task name'),
                        ),
                      );
                      return;
                    }
                    if (_selectedCategory.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a category'),
                        ),
                      );
                      return;
                    }

                    widget.onItemAdded(
                      _titleController.text.trim(),
                      _selectedCategory,
                      _notesController.text.isEmpty
                          ? null
                          : _notesController.text.trim(),
                      _selectedDueDate,
                      _isPriority,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('ADD TASK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
