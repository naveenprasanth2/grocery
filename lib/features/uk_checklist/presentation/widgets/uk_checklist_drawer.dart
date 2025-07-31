import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/uk_checklist_provider.dart';

class UKChecklistDrawer extends StatelessWidget {
  final UKChecklistProvider checklistProvider;
  final VoidCallback onClearCompleted;
  final VoidCallback onClearAll;

  const UKChecklistDrawer({
    super.key,
    required this.checklistProvider,
    required this.onClearCompleted,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'UK Moving Checklist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${checklistProvider.completedItems}/${checklistProvider.totalItems} Tasks Completed',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: checklistProvider.totalItems > 0
                      ? checklistProvider.completedItems /
                            checklistProvider.totalItems
                      : 0,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          ...checklistProvider.categories.map((category) {
            final categoryItems = checklistProvider.items
                .where((item) => item.category == category)
                .toList();
            final completedItems = categoryItems
                .where((item) => item.isChecked)
                .length;

            return ListTile(
              title: Text(category),
              subtitle: Text(
                '$completedItems/${categoryItems.length} completed',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Provider.of<UKChecklistProvider>(context, listen: false);
                // TODO: Implement category filtering
              },
            );
          }).toList(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear Completed Tasks'),
            onTap: () {
              Navigator.pop(context);
              onClearCompleted();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear All Tasks'),
            onTap: () {
              Navigator.pop(context);
              onClearAll();
            },
          ),
          const Divider(),
          AboutListTile(
            icon: const Icon(Icons.info_outline),
            applicationName: 'UK Moving Checklist',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2025 UK Moving Checklist',
            aboutBoxChildren: const [
              SizedBox(height: 10),
              Text('A checklist app to help you organize your move to the UK.'),
            ],
          ),
        ],
      ),
    );
  }
}
