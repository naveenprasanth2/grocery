import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class GrocerySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onSearchChanged;
  final VoidCallback onSearchClosed;

  const GrocerySearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onSearchChanged,
    required this.onSearchClosed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimationDuration,
      height: isSearching ? 60 : 0,
      child: isSearching
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onSearchClosed,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => onSearchChanged(),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
