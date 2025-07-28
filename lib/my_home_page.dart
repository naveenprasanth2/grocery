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
    TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        actionsIconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              DateFormat('dd-MM-yyyy').format(DateTime.now()),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total Items: ${tileList.count}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tileList.items.length,
                itemBuilder: (context, index) {
                  final item = tileList.items[index];
                  return ListTile(
                    leading: Icon(
                      Icons.food_bank,
                      size: 40,
                      color: Colors.yellow,
                    ),
                    title: Text(item.title),
                    trailing: Checkbox(
                      value: item.isChecked,
                      onChanged: (bool? value) {
                        if (value != null) {
                          tileList.toggle(index, value);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Add Item',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        tileList.addItem(controller.text.trim());
                        controller.clear();
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
