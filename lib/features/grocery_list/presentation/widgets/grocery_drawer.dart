import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/grocery_list_provider.dart';
import '../../../expense_tracker/presentation/screens/expense_screen.dart';
import '../../../expense_tracker/presentation/screens/history_screen.dart';

class GroceryDrawer extends StatelessWidget {
  const GroceryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shopping_basket, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage expenses',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.green.shade600),
            title: const Text('Shopping List'),
            selected: true,
            selectedTileColor: Colors.green.shade50,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.analytics, color: Colors.blue.shade600),
            title: const Text('Expense Tracker'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpenseScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: Colors.purple.shade600),
            title: const Text('Shopping History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          const Divider(),
          Consumer<GroceryListProvider>(
            builder: (context, groceryProvider, child) {
              return ListTile(
                leading: Icon(
                  Icons.attach_money,
                  color: Colors.orange.shade600,
                ),
                title: const Text('Current Total'),
                subtitle: Text('\$${groceryProvider.totalCost.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.info_outline),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey.shade600),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _showSettingsDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.grey.shade600),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            const Text('Settings'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              trailing: Switch(value: false, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: const Icon(Icons.shopping_cart, color: Colors.white, size: 32),
      ),
      children: const [
        Text(AppConstants.appDescription),
        SizedBox(height: 16),
        Text('Features:'),
        Text('• Smart categorization'),
        Text('• Barcode scanning'),
        Text('• Shopping templates'),
        Text('• List sharing'),
        Text('• Shopping timer'),
        Text('• Beautiful modern UI'),
      ],
    );
  }
}
