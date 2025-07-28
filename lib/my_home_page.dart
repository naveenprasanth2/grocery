import 'package:flutter/material.dart';
import 'package:grocery/provider/checklist_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final tileList = context.watch<CheckBoxModel>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actionsIconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  DateFormat('dd-MM-yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Grocery Checklist',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Total: ${tileList.count}',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.shade400,
                        elevation: 2,
                      ),
                      Chip(
                        label: Text(
                          'Remaining: ${tileList.items.where((x) => !x.isChecked).length}',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange.shade400,
                        elevation: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: tileList.items.isEmpty
                  ? Center(
                      child: Text(
                        'No items yet. Add your first grocery item!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: tileList.items.length,
                      separatorBuilder: (context, idx) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = tileList.items[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.isChecked
                                  ? Colors.green.shade200
                                  : Colors.yellow.shade600,
                              child: Icon(Icons.food_bank, color: Colors.white),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: item.isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: item.isChecked
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            trailing: Checkbox(
                              value: item.isChecked,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  tileList.toggle(index, value);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          backgroundColor: Colors.green.shade600,
          icon: Icon(Icons.add, color: Colors.white),
          label: Text('Add Item', style: TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                final width = MediaQuery.of(context).size.width * 0.8;
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Add Grocery Item',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SizedBox(
                    width: width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Item name',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty &&
                            quantityController.text.trim().isNotEmpty) {
                          tileList.addItem(
                            '${nameController.text.trim()} (${quantityController.text.trim()})',
                          );
                          nameController.clear();
                          quantityController.clear();
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
