import 'package:flutter/material.dart';

class UKChecklistFab extends StatelessWidget {
  final VoidCallback onPressed;
  final AnimationController animationController;

  const UKChecklistFab({
    super.key,
    required this.onPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    // Animations for the FAB
    final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    final rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    return ScaleTransition(
      scale: scaleAnimation,
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 0.125).animate(rotateAnimation),
        child: FloatingActionButton(
          onPressed: onPressed,
          tooltip: 'Add Task',
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 4.0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
