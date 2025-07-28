import 'package:flutter/material.dart';
import 'package:grocery/provider/checklist_provider.dart';
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
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_basket, color: Colors.green.shade700, size: 28),
            SizedBox(width: 10),
            Text(
              'Grocery List',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        toolbarHeight: 60,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 18.0,
                horizontal: 20,
              ),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: Colors.green.shade700,
                            size: 22,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Total: ',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${tileList.count}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 28),
                      Row(
                        children: [
                          Icon(
                            Icons.pending_actions,
                            color: Colors.orange.shade700,
                            size: 22,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Remaining: ',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${tileList.items.where((x) => !x.isChecked).length}',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                  : ReorderableListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: tileList.items.length,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex -= 1;
                        tileList.moveItem(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final item = tileList.items[index];
                        return Card(
                          key: ValueKey(item.title + index.toString()),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Icon(
                                    Icons.drag_handle_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(
                                    left: 0,
                                    right: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: item.isChecked
                                        ? Colors.green.shade200
                                        : Colors.yellow.shade600,
                                    child: Icon(
                                      Icons.food_bank,
                                      color: Colors.white,
                                    ),
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
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blueGrey,
                                        ),
                                        tooltip: 'Edit',
                                        onPressed: () {
                                          final editNameController =
                                              TextEditingController(
                                                text: item.title
                                                    .split(' (')
                                                    .first,
                                              );
                                          final editQuantityController =
                                              TextEditingController(
                                                text: item.title.contains('(')
                                                    ? item.title
                                                          .split('(')
                                                          .last
                                                          .replaceAll(')', '')
                                                    : '',
                                              );
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              final width =
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.8;
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                title: Text(
                                                  'Edit Item',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: SizedBox(
                                                  width: width,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            editNameController,
                                                        decoration: InputDecoration(
                                                          labelText:
                                                              'Item name',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                      ),
                                                      SizedBox(height: 12),
                                                      TextField(
                                                        controller:
                                                            editQuantityController,
                                                        decoration: InputDecoration(
                                                          labelText: 'Quantity',
                                                          border:
                                                              OutlineInputBorder(),
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
                                                      backgroundColor:
                                                          Colors.green.shade600,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      if (editNameController
                                                              .text
                                                              .trim()
                                                              .isNotEmpty &&
                                                          editQuantityController
                                                              .text
                                                              .trim()
                                                              .isNotEmpty) {
                                                        tileList.updateItem(
                                                          index,
                                                          '${editNameController.text.trim()} (${editQuantityController.text.trim()})',
                                                        );
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: Text('Update'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      Checkbox(
                                        value: item.isChecked,
                                        activeColor: Colors.green,
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            tileList.toggle(index, value);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Delete Item'),
                                        content: Text(
                                          'Are you sure you want to delete this item?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () {
                                              tileList.deleteItem(index);
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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
                      child: Text('Add', style: TextStyle(color: Colors.white)),
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
