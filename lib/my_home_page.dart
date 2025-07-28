import 'package:flutter/material.dart';
import 'package:grocery/provider/checklist_provider.dart';
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatsCards(tileList),
            _buildSearchBar(),
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
      actions: [
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
            }
          },
          itemBuilder: (context) => [
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
                    icon: Icons.check_circle,
                    label: 'Done',
                    value: '$completedItems',
                    color: Colors.green,
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
    tileList.addItem('$itemName (1)');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to your list'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildItemsList(CheckBoxModel tileList, BuildContext context) {
    var filteredItems = tileList.items.asMap().entries.where((entry) {
      if (_searchController.text.isEmpty) return true;
      return entry.value.title.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
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
              key: ValueKey(item.title + actualIndex.toString()),
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
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 0, right: 16),
                        leading: Hero(
                          tag: 'avatar_${item.title}_$actualIndex',
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
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                      Icon(
                        Icons.add_shopping_cart,
                        color: Colors.green.shade600,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Add New Item',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'What do you need?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: Icon(Icons.shopping_basket_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => setModalState(() {}),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            prefixIcon: Icon(Icons.numbers),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: 'Price (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            prefixIcon: Icon(Icons.attach_money),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (nameController.text.isEmpty) ...[
                    SizedBox(height: 20),
                    Text(
                      'Quick suggestions:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions.take(6).map((suggestion) {
                        return ActionChip(
                          label: Text(suggestion),
                          onPressed: () {
                            nameController.text = suggestion;
                            quantityController.text = '1';
                            setModalState(() {});
                          },
                          backgroundColor: Colors.green.shade50,
                          labelStyle: TextStyle(color: Colors.green.shade700),
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed:
                              nameController.text.trim().isNotEmpty &&
                                  quantityController.text.trim().isNotEmpty
                              ? () {
                                  final priceText =
                                      priceController.text.trim().isNotEmpty
                                      ? ' - \$${priceController.text.trim()}'
                                      : '';
                                  tileList.addItem(
                                    '${nameController.text.trim()} (${quantityController.text.trim()})$priceText',
                                  );
                                  nameController.clear();
                                  quantityController.clear();
                                  priceController.clear();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${nameController.text} added to your list!',
                                      ),
                                      backgroundColor: Colors.green.shade600,
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
}
