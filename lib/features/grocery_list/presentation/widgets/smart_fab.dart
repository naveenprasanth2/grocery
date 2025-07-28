import 'package:flutter/material.dart';

class SmartFAB extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onPressed;

  const SmartFAB({
    super.key,
    required this.animationController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticOut,
        ),
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text(
          'Add Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
