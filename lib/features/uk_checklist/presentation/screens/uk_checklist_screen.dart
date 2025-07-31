import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/uk_checklist_provider.dart';
import '../widgets/uk_checklist_app_bar.dart';
import '../widgets/uk_checklist_drawer.dart';
import '../widgets/uk_checklist_stats_card.dart';
import '../widgets/uk_search_bar.dart';
import '../widgets/uk_category_filter_bar.dart';
import '../widgets/uk_checklist_items_list.dart';
import '../widgets/uk_checklist_empty_state.dart';
import '../widgets/uk_checklist_fab.dart';
import '../widgets/dialogs/add_checklist_item_dialog.dart';
import '../../../../core/constants/app_constants.dart';

class UKChecklistScreen extends StatefulWidget {
  const UKChecklistScreen({super.key});

  @override
  State<UKChecklistScreen> createState() => _UKChecklistScreenState();
}

class _UKChecklistScreenState extends State<UKChecklistScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  String _selectedCategoryFilter = 'All';
  bool _showOnlyUnchecked = false;
  bool _showOnlyPriority = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Populate with default items if it's the first run
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UKChecklistProvider>(context, listen: false);
      provider.populateWithDefaultItems();
    });
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

  void _toggleShowOnlyPriority() {
    setState(() {
      _showOnlyPriority = !_showOnlyPriority;
    });
  }

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddChecklistItemDialog(
        onItemAdded: (title, category, notes, dueDate, isPriority) {
          final provider = context.read<UKChecklistProvider>();
          provider.addItem(
            title,
            category,
            notes: notes,
            dueDate: dueDate,
            isPriority: isPriority,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UKChecklistProvider>(
      builder: (context, checklistProvider, child) {
        final filteredItems = checklistProvider.getFilteredItems(
          searchQuery: _isSearching ? _searchController.text : null,
          categoryFilter: _selectedCategoryFilter,
          showOnlyUnchecked: _showOnlyUnchecked,
          showOnlyPriority: _showOnlyPriority,
        );

        return Scaffold(
          appBar: UKChecklistAppBar(
            isSearching: _isSearching,
            searchController: _searchController,
            onToggleSearch: _toggleSearch,
            onToggleShowUnchecked: _toggleShowOnlyUnchecked,
            showOnlyUnchecked: _showOnlyUnchecked,
            onToggleShowPriority: _toggleShowOnlyPriority,
            showOnlyPriority: _showOnlyPriority,
            listSize: filteredItems.length,
          ),
          drawer: UKChecklistDrawer(
            checklistProvider: checklistProvider,
            onClearCompleted: checklistProvider.clearCompleted,
            onClearAll: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Items'),
                  content: const Text(
                    'Are you sure you want to clear all items?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        checklistProvider.clearAll();
                        Navigator.pop(context);
                      },
                      child: const Text('CLEAR ALL'),
                    ),
                  ],
                ),
              );
            },
          ),
          body: Column(
            children: [
              UKChecklistStatsCard(
                totalItems: checklistProvider.totalItems,
                completedItems: checklistProvider.completedItems,
                remainingItems: checklistProvider.remainingItems,
                completionPercentage: checklistProvider.completionPercentage,
              ),
              if (_isSearching)
                UKSearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onClear: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              UKCategoryFilterBar(
                categories: ['All', ...checklistProvider.categories],
                selectedCategory: _selectedCategoryFilter,
                onCategorySelected: _onCategoryFilterChanged,
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? UKChecklistEmptyState(
                        isSearching: _isSearching,
                        isFiltering:
                            _selectedCategoryFilter != 'All' ||
                            _showOnlyUnchecked ||
                            _showOnlyPriority,
                        onAddNewItem: _showAddItemDialog,
                      )
                    : UKChecklistItemsList(
                        items: filteredItems,
                        onToggleItem: checklistProvider.toggleChecked,
                        onDeleteItem: checklistProvider.deleteItemById,
                        onEditItem: (item) {
                          // Show edit dialog - implementation to be added later
                        },
                        listAnimationController: _listAnimationController,
                      ),
              ),
            ],
          ),
          floatingActionButton: UKChecklistFab(
            onPressed: _showAddItemDialog,
            animationController: _fabAnimationController,
          ),
        );
      },
    );
  }
}
