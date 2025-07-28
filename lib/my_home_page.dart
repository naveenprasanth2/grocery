import 'package:flutter/material.dart';
import 'package:grocery/provider/checklist_provider.dart';
import 'package:grocery/provider/expense_provider.dart';
import 'package:grocery/screens/expense_screen.dart';
import 'package:grocery/screens/history_screen.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({required this.title, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedCategoryFilter = 'All';
  bool _showOnlyUnchecked = false;

  // Smart suggestions for grocery items
  final List<String> _suggestions = [
    'Milk',
    'Bread',
    'Eggs',
    'Butter',
    'Cheese',
    'Yogurt',
    'Chicken',
    'Beef',
    'Apples',
    'Bananas',
    'Oranges',
    'Tomatoes',
    'Onions',
    'Potatoes',
    'Carrots',
    'Rice',
    'Pasta',
    'Olive Oil',
    'Salt',
    'Sugar',
    'Coffee',
    'Tea',
    'Cereal',
  ];

  final Map<String, IconData> _categoryIcons = {
    'All': Icons.apps,
    'Dairy': Icons.local_drink,
    'Meat': Icons.set_meal,
    'Fruits': Icons.apple,
    'Vegetables': Icons.eco,
    'Grains': Icons.grain,
    'Beverages': Icons.coffee,
    'Other': Icons.shopping_basket,
  };

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimationController.forward();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _categorizeItem(String itemName) {
    final name = itemName.toLowerCase();
    if (['milk', 'cheese', 'butter', 'yogurt', 'cream'].any(name.contains))
      return 'Dairy';
    if (['chicken', 'beef', 'pork', 'fish', 'meat'].any(name.contains))
      return 'Meat';
    if (['apple', 'banana', 'orange', 'grape', 'berry'].any(name.contains))
      return 'Fruits';
    if (['tomato', 'onion', 'potato', 'carrot', 'lettuce'].any(name.contains))
      return 'Vegetables';
    if (['rice', 'bread', 'pasta', 'cereal', 'flour'].any(name.contains))
      return 'Grains';
    if (['coffee', 'tea', 'juice', 'soda', 'water'].any(name.contains))
      return 'Beverages';
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    final tileList = context.watch<CheckBoxModel>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: _buildAppBar(context, tileList),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatsCards(tileList),
            _buildSearchBar(),
            _buildCategoryFilterBar(),
            Expanded(
              child: tileList.items.isEmpty
                  ? _buildEmptyState()
                  : _buildItemsList(tileList, context),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSmartFAB(
        context,
        nameController,
        quantityController,
        priceController,
        tileList,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    CheckBoxModel tileList,
  ) {
    return AppBar(
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
            'Smart Grocery',
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.qr_code_scanner, color: Colors.green.shade700),
          onPressed: () => _showBarcodeScanDialog(),
          tooltip: 'Scan Barcode',
        ),
        IconButton(
          icon: Icon(Icons.timer, color: Colors.green.shade700),
          onPressed: () => _showShoppingTimerDialog(),
          tooltip: 'Shopping Timer',
        ),
        IconButton(
          icon: Icon(Icons.search, color: Colors.green.shade700),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
            });
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.green.shade700),
          onSelected: (value) {
            switch (value) {
              case 'templates':
                _showTemplatesDialog();
                break;
              case 'share_list':
                _shareShoppingList();
                break;
              case 'clear_completed':
                // Clear completed items
                for (int i = tileList.items.length - 1; i >= 0; i--) {
                  if (tileList.items[i].isChecked) {
                    tileList.deleteItem(i);
                  }
                }
                break;
              case 'clear_all':
                // Clear all items
                while (tileList.items.isNotEmpty) {
                  tileList.deleteItem(0);
                }
                break;
              case 'save_to_history':
                _saveToHistory(context, tileList);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'templates',
              child: Row(
                children: [
                  Icon(Icons.bookmark, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Shopping Templates'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share_list',
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('Share List'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'save_to_history',
              child: Row(
                children: [
                  Icon(Icons.save, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Save to History'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_completed',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Clear Completed'),
                ],
              ),
            ),
            PopupMenuItem(
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

  Widget _buildStatsCards(CheckBoxModel tileList) {
    final completedItems = tileList.items.where((x) => x.isChecked).length;
    final totalItems = tileList.count;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatChip(
                    icon: Icons.list_alt,
                    label: 'Total',
                    value: '$totalItems',
                    color: Colors.blue,
                  ),
                  _buildStatChip(
                    icon: Icons.shopping_cart,
                    label: 'Remaining',
                    value: '${totalItems - completedItems}',
                    color: Colors.orange,
                  ),
                  _buildStatChip(
                    icon: Icons.attach_money,
                    label: 'Total Cost',
                    value: '\$${tileList.totalCost.toStringAsFixed(2)}',
                    color: Colors.purple,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Progress',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade600,
                ),
                minHeight: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isSearching ? 60 : 0,
      child: _isSearching
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild for filtering
                },
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildCategoryFilterBar() {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categoryIcons.keys.length,
              itemBuilder: (context, index) {
                final category = _categoryIcons.keys.elementAt(index);
                final isSelected = _selectedCategoryFilter == category;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcons[category],
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Text(category),
                      ],
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryFilter = selected ? category : 'All';
                      });
                    },
                    selectedColor: Colors.green.shade600,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _showOnlyUnchecked
                  ? Colors.orange.shade600
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.checklist_rtl,
                color: _showOnlyUnchecked ? Colors.white : Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  _showOnlyUnchecked = !_showOnlyUnchecked;
                });
              },
              tooltip: 'Show only pending items',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Your grocery list is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first item to get started!',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _suggestions.take(3).map((suggestion) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  label: Text(suggestion),
                  onPressed: () => _quickAddItem(suggestion),
                  backgroundColor: Colors.green.shade50,
                  labelStyle: TextStyle(color: Colors.green.shade700),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _quickAddItem(String itemName) {
    final tileList = context.read<CheckBoxModel>();
    tileList.addItem(itemName, quantity: 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to your list'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shopping_basket, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text(
                  'Smart Grocery',
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
            title: Text('Shopping List'),
            selected: true,
            selectedTileColor: Colors.green.shade50,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.analytics, color: Colors.blue.shade600),
            title: Text('Expense Tracker'),
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
            title: Text('Shopping History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          Divider(),
          Consumer<CheckBoxModel>(
            builder: (context, tileList, child) {
              return ListTile(
                leading: Icon(
                  Icons.attach_money,
                  color: Colors.orange.shade600,
                ),
                title: Text('Current Total'),
                subtitle: Text('\$${tileList.totalCost.toStringAsFixed(2)}'),
                trailing: Icon(Icons.info_outline),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey.shade600),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _showSettingsDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.grey.shade600),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _saveToHistory(BuildContext context, CheckBoxModel tileList) {
    if (tileList.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No items to save'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final storeController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.save, color: Colors.blue.shade600),
              SizedBox(width: 8),
              Text('Save to History'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save this shopping list to your history?'),
              SizedBox(height: 16),
              TextField(
                controller: storeController,
                decoration: InputDecoration(
                  labelText: 'Store Name (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.store),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.read<ExpenseProvider>().addToHistory(
                  tileList.items,
                  storeController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Shopping list saved to history!'),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text('Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Grocery',
      applicationVersion: '2.0.0',
      applicationIcon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.shopping_cart, color: Colors.white, size: 32),
      ),
      children: [
        Text(
          'A modern, feature-rich grocery shopping app with smart organization.',
        ),
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

  Widget _buildItemsList(CheckBoxModel tileList, BuildContext context) {
    var filteredItems = tileList.items.asMap().entries.where((entry) {
      final item = entry.value;

      // Text search filter
      if (_searchController.text.isNotEmpty) {
        if (!item.title.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        )) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategoryFilter != 'All') {
        final category = _categorizeItem(item.title);
        if (category != _selectedCategoryFilter) {
          return false;
        }
      }

      // Show only unchecked filter
      if (_showOnlyUnchecked && item.isChecked) {
        return false;
      }

      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 500));
        setState(() {});
      },
      child: ReorderableListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredItems.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex -= 1;
          final actualOldIndex = filteredItems[oldIndex].key;
          final actualNewIndex = filteredItems[newIndex].key;
          tileList.moveItem(actualOldIndex, actualNewIndex);
        },
        itemBuilder: (context, index) {
          final entry = filteredItems[index];
          final actualIndex = entry.key;
          final item = entry.value;
          final category = _categorizeItem(item.title);

          return SlideTransition(
            key: ValueKey('slide_${item.title}_$actualIndex'),
            position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _listAnimationController,
                    curve: Interval(
                      index * 0.1,
                      1.0,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                ),
            child: Card(
              key: ValueKey('card_${item.title}_$actualIndex'),
              margin: EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      item.isChecked ? Colors.green.shade50 : Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        key: ValueKey('drag_handle_${item.title}_$actualIndex'),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 20,
                        ),
                        child: Icon(
                          Icons.drag_handle,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      key: ValueKey('expanded_${item.title}_$actualIndex'),
                      child: ListTile(
                        key: ValueKey('list_tile_${item.title}_$actualIndex'),
                        contentPadding: EdgeInsets.only(left: 0, right: 16),
                        leading: Hero(
                          tag: 'avatar_${item.title.hashCode}_$actualIndex',
                          child: CircleAvatar(
                            backgroundColor: item.isChecked
                                ? Colors.green.shade200
                                : _getCategoryColor(category),
                            child: Icon(
                              _categoryIcons[category] ?? Icons.shopping_basket,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  decoration: item.isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: item.isChecked
                                      ? Colors.grey.shade500
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(
                                  category,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getCategoryColor(category),
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 20),
                              color: Colors.blue.shade600,
                              onPressed: () => _showEditDialog(
                                context,
                                tileList,
                                actualIndex,
                                item,
                              ),
                            ),
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: item.isChecked,
                                activeColor: Colors.green.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    tileList.toggle(actualIndex, value);
                                    _showCompletionFeedback(item.title, value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        onLongPress: () => _showDeleteDialog(
                          context,
                          tileList,
                          actualIndex,
                          item.title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Dairy':
        return Colors.blue.shade600;
      case 'Meat':
        return Colors.red.shade600;
      case 'Fruits':
        return Colors.orange.shade600;
      case 'Vegetables':
        return Colors.green.shade600;
      case 'Grains':
        return Colors.amber.shade700;
      case 'Beverages':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  void _showCompletionFeedback(String itemTitle, bool isCompleted) {
    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('✓ $itemTitle completed!'),
            ],
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green.shade600,
        ),
      );
    }
  }

  void _showEditDialog(
    BuildContext context,
    CheckBoxModel tileList,
    int index,
    dynamic item,
  ) {
    final editNameController = TextEditingController(
      text: item.title.split(' (').first,
    );
    final editQuantityController = TextEditingController(
      text: item.title.contains('(')
          ? item.title.split('(').last.replaceAll(')', '')
          : '1',
    );
    final editPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width * 0.85;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue.shade600),
              SizedBox(width: 8),
              Text('Edit Item', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editNameController,
                  decoration: InputDecoration(
                    labelText: 'Item name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.shopping_basket_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: editQuantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: editPriceController,
                        decoration: InputDecoration(
                          labelText: 'Price (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (editNameController.text.trim().isNotEmpty &&
                    editQuantityController.text.trim().isNotEmpty) {
                  final priceText = editPriceController.text.trim().isNotEmpty
                      ? ' - \$${editPriceController.text.trim()}'
                      : '';
                  tileList.updateItem(
                    index,
                    '${editNameController.text.trim()} (${editQuantityController.text.trim()})$priceText',
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CheckBoxModel tileList,
    int index,
    String itemTitle,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade600),
            SizedBox(width: 8),
            Text('Delete Item'),
          ],
        ),
        content: Text('Are you sure you want to delete "$itemTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              tileList.deleteItem(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$itemTitle deleted'),
                  backgroundColor: Colors.red.shade600,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      // Add undo functionality here if needed
                    },
                  ),
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartFAB(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController quantityController,
    TextEditingController priceController,
    CheckBoxModel tileList,
  ) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.elasticOut,
        ),
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade600,
        icon: Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text(
          'Add Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: () => _showSmartAddDialog(
          context,
          nameController,
          quantityController,
          priceController,
          tileList,
        ),
      ),
    );
  }

  void _showSmartAddDialog(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController quantityController,
    TextEditingController priceController,
    CheckBoxModel tileList,
  ) {
    String selectedCategory = 'Other';
    bool isUrgent = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.green.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade200,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Item',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'Add items to your smart grocery list',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Item Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'What do you need?',
                        labelStyle: TextStyle(color: Colors.green.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.shopping_basket_outlined,
                          color: Colors.green.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.green.shade600,
                            width: 2,
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => setModalState(() {}),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Quantity and Price Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: quantityController,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              labelStyle: TextStyle(
                                color: Colors.orange.shade600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.numbers,
                                color: Colors.orange.shade600,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.orange.shade600,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => setModalState(() {}),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: priceController,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              labelStyle: TextStyle(
                                color: Colors.purple.shade600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: Colors.purple.shade600,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.purple.shade600,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Category Selection
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              [
                                'Dairy',
                                'Meat',
                                'Fruits',
                                'Vegetables',
                                'Grains',
                                'Beverages',
                                'Other',
                              ].map((category) {
                                final isSelected = selectedCategory == category;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                _getCategoryColor(
                                                  category,
                                                ).withOpacity(0.8),
                                                _getCategoryColor(category),
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? _getCategoryColor(category)
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: _getCategoryColor(
                                                  category,
                                                ).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _categoryIcons[category],
                                          size: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : _getCategoryColor(category),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          category,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Urgent Toggle
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          color: isUrgent
                              ? Colors.red.shade600
                              : Colors.grey.shade400,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mark as urgent',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Switch(
                          value: isUrgent,
                          onChanged: (value) {
                            setModalState(() {
                              isUrgent = value;
                            });
                          },
                          activeColor: Colors.red.shade600,
                        ),
                      ],
                    ),
                  ),

                  if (nameController.text.isEmpty) ...[
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.blue.shade600,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Quick suggestions:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _suggestions.take(6).map((suggestion) {
                              return GestureDetector(
                                onTap: () {
                                  nameController.text = suggestion;
                                  quantityController.text = '1';
                                  setModalState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.shade200,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    suggestion,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  nameController.text.trim().isNotEmpty &&
                                      quantityController.text.trim().isNotEmpty
                                  ? [
                                      Colors.green.shade500,
                                      Colors.green.shade700,
                                    ]
                                  : [
                                      Colors.grey.shade300,
                                      Colors.grey.shade400,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow:
                                nameController.text.trim().isNotEmpty &&
                                    quantityController.text.trim().isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: Colors.green.shade300,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed:
                                nameController.text.trim().isNotEmpty &&
                                    quantityController.text.trim().isNotEmpty
                                ? () {
                                    String itemTitle = nameController.text
                                        .trim();
                                    if (isUrgent) {
                                      itemTitle = '🔥 $itemTitle';
                                    }

                                    final price =
                                        double.tryParse(
                                          priceController.text.trim(),
                                        ) ??
                                        0.0;
                                    final quantity =
                                        int.tryParse(
                                          quantityController.text.trim(),
                                        ) ??
                                        1;

                                    tileList.addItem(
                                      itemTitle,
                                      price: price,
                                      quantity: quantity,
                                    );

                                    nameController.clear();
                                    quantityController.clear();
                                    priceController.clear();
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Item added to your list!'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            child: Text(
                              'Add to List',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBarcodeScanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.blue.shade600),
            SizedBox(width: 8),
            Text('Scan Barcode'),
          ],
        ),
        content: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
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
              SizedBox(height: 16),
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
            child: Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Simulate adding a scanned item
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
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
            child: Text('Simulate Scan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showShoppingTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.timer, color: Colors.orange.shade600),
            SizedBox(width: 8),
            Text('Shopping Timer'),
          ],
        ),
        content: Container(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, size: 60, color: Colors.orange.shade600),
              SizedBox(height: 16),
              Text(
                '45:30',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                ),
              ),
              SizedBox(height: 8),
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
            child: Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Timer started! Happy shopping!'),
                  backgroundColor: Colors.orange.shade600,
                ),
              );
            },
            child: Text('Start Timer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTemplatesDialog() {
    final templates = [
      {
        'name': 'Weekly Groceries',
        'items': ['Milk', 'Bread', 'Eggs', 'Fruits', 'Vegetables'],
      },
      {
        'name': 'Party Supplies',
        'items': ['Chips', 'Drinks', 'Cake', 'Ice cream', 'Napkins'],
      },
      {
        'name': 'Breakfast Essentials',
        'items': ['Cereal', 'Milk', 'Bananas', 'Coffee', 'Yogurt'],
      },
      {
        'name': 'Cooking Basics',
        'items': ['Oil', 'Salt', 'Spices', 'Onions', 'Garlic'],
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.bookmark, color: Colors.purple.shade600),
            SizedBox(width: 8),
            Text('Shopping Templates'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade600,
                    child: Icon(Icons.list, color: Colors.white),
                  ),
                  title: Text(
                    template['name'] as String,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${(template['items'] as List).length} items',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _loadTemplate(template['items'] as List<String>);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _loadTemplate(List<String> items) {
    final tileList = Provider.of<CheckBoxModel>(context, listen: false);
    for (String item in items) {
      tileList.addItem('$item (1)');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Template loaded! ${items.length} items added.'),
          ],
        ),
        backgroundColor: Colors.purple.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareShoppingList() {
    final tileList = Provider.of<CheckBoxModel>(context, listen: false);
    final items = tileList.items;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your shopping list is empty!'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    String shareText = '🛒 My Shopping List:\n\n';
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      shareText += '${i + 1}. ${item.title} ${item.isChecked ? '✅' : '⭕'}\n';
    }
    shareText += '\nShared from My Grocery App 📱';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.share, color: Colors.blue.shade600),
            SizedBox(width: 8),
            Text('Share Shopping List'),
          ],
        ),
        content: Container(
          height: 200,
          child: SingleChildScrollView(
            child: Text(shareText, style: TextStyle(fontSize: 14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Shopping list shared successfully!'),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text('Share', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
