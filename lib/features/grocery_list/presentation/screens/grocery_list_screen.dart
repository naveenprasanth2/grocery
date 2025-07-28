import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/grocery_list_provider.dart';
import '../widgets/grocery_app_bar.dart';
import '../widgets/grocery_drawer.dart';
import '../widgets/stats_cards.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/grocery_items_list.dart';
import '../widgets/empty_state.dart';
import '../widgets/smart_fab.dart';
import '../widgets/dialogs/add_item_dialog.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  final TextEditingController _searchController = TextEditingController();
  
  bool _isSearching = false;
  String _selectedCategoryFilter = 'All';
  bool _showOnlyUnchecked = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: AppConstants.shortAnimationDuration,
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  void _onCategoryFilterChanged(String category) {
    setState(() {
      _selectedCategoryFilter = category;
    });
  }

  void _toggleShowOnlyUnchecked() {
    setState(() {
      _showOnlyUnchecked = !_showOnlyUnchecked;
    });
  }

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemDialog(
        onItemAdded: (title, quantity, price, isUrgent) {
          final provider = context.read<GroceryListProvider>();
          String finalTitle = title;
          if (isUrgent) {
            finalTitle = '🔥 $title';
          }
          provider.addItem(finalTitle, price: price, quantity: quantity);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryListProvider>(
      builder: (context, groceryProvider, child) {
        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          appBar: GroceryAppBar(
            onSearchToggle: _toggleSearch,
            onMenuAction: (action) => _handleMenuAction(action, groceryProvider),
          ),
          drawer: const GroceryDrawer(),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatsCards(groceryProvider: groceryProvider),
                GrocerySearchBar(
                  controller: _searchController,
                  isSearching: _isSearching,
                  onSearchChanged: () => setState(() {}),
                  onSearchClosed: () => setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  }),
                ),
                CategoryFilterBar(
                  selectedCategory: _selectedCategoryFilter,
                  showOnlyUnchecked: _showOnlyUnchecked,
                  onCategoryChanged: _onCategoryFilterChanged,
                  onToggleUnchecked: _toggleShowOnlyUnchecked,
                ),
                Expanded(
                  child: groceryProvider.items.isEmpty
                      ? EmptyState(
                          onQuickAdd: (item) => groceryProvider.addItem(item, quantity: 1),
                        )
                      : GroceryItemsList(
                          searchQuery: _searchController.text,
                          categoryFilter: _selectedCategoryFilter,
                          showOnlyUnchecked: _showOnlyUnchecked,
                          animationController: _listAnimationController,
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: SmartFAB(
            animationController: _fabAnimationController,
            onPressed: _showAddItemDialog,
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action, GroceryListProvider provider) {
    switch (action) {
      case 'templates':
        // TODO: Show templates dialog
        break;
      case 'share_list':
        // TODO: Show share dialog
        break;
      case 'clear_completed':
        provider.clearCompleted();
        _showSnackBar('Completed items cleared');
        break;
      case 'clear_all':
        provider.clearAll();
        _showSnackBar('All items cleared');
        break;
      case 'save_to_history':
        // TODO: Save to history
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    );
  }
}
