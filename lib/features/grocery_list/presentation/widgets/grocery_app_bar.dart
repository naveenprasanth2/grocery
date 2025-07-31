import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/grocery_list_provider.dart';

class GroceryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchToggle;
  final Function(String) onMenuAction;

  const GroceryAppBar({
    super.key,
    required this.onSearchToggle,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black), // Black drawer icon
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_basket, color: Colors.green.shade700, size: 28),
          const SizedBox(width: 10),
          Text(
            AppConstants.appName,
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      toolbarHeight: 60,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.qr_code_scanner, color: Colors.green.shade700),
          onPressed: () => _showQRCodeScanDialog(context),
          tooltip: 'Scan QR Code',
        ),
        IconButton(
          icon: Icon(Icons.search, color: Colors.green.shade700),
          onPressed: onSearchToggle,
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.green.shade700),
          onSelected: onMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'templates',
              child: Row(
                children: [
                  Icon(Icons.bookmark, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Shopping Templates'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share_list',
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('Share List'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'save_to_history',
              child: Row(
                children: [
                  Icon(Icons.save, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Save to History'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_completed',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Clear Completed'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(Icons.clear_all, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Clear All'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showQRCodeScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _simulateQRScan(context);
            },
            child: const Text(
              'Simulate Scan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _importGroceryList(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.download, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('Import Grocery List'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Found ${data['items'].length} items in the list:'),
            const SizedBox(height: 8),
            Text(
              data['name'] ?? 'Shared Grocery List',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Do you want to add these items to your current list?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            onPressed: () {
              final provider = context.read<GroceryListProvider>();
              final List<dynamic> items = data['items'];

              for (var item in items) {
                provider.addItem(
                  item['title'] ?? 'Unknown Item',
                  price: (item['price'] ?? 0.0).toDouble(),
                  quantity: item['quantity'] ?? 1,
                );
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${items.length} items imported successfully!'),
                  backgroundColor: Colors.green.shade600,
                ),
              );
            },
            child: const Text(
              'Import Items',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRResultDialog(BuildContext context, String qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.qr_code, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            const Text('QR Code Scanned'),
          ],
        ),
        content: Text(qrData),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _simulateQRScan(BuildContext context) {
    // Simulate scanning a grocery list QR code
    const sampleList = {
      'type': 'grocery_list',
      'name': 'Sample Shopping List',
      'items': [
        {'title': 'Milk', 'price': 3.99, 'quantity': 1},
        {'title': 'Bread', 'price': 2.50, 'quantity': 2},
        {'title': 'Eggs', 'price': 4.99, 'quantity': 1},
      ],
    };

    _importGroceryList(context, sampleList);
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
