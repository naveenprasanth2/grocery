import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

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
          onPressed: () => _showBarcodeScanDialog(context),
          tooltip: 'Scan Barcode',
        ),
        IconButton(
          icon: Icon(Icons.timer, color: Colors.green.shade700),
          onPressed: () => _showShoppingTimerDialog(context),
          tooltip: 'Shopping Timer',
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

  void _showBarcodeScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            const Text('Scan Barcode'),
          ],
        ),
        content: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera scanner would\nopen here',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Product scanned successfully!'),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                ),
              );
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

  void _showShoppingTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.timer, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Shopping Timer'),
          ],
        ),
        content: SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, size: 60, color: Colors.orange.shade600),
              const SizedBox(height: 16),
              Text(
                '45:30',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Shopping time',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Timer started! Happy shopping!'),
                  backgroundColor: Colors.orange.shade600,
                ),
              );
            },
            child: const Text(
              'Start Timer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
