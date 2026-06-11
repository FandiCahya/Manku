import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class QuickAddFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const QuickAddFAB({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: context.colors.primary,
      elevation: 8,
      child: Icon(Icons.add, color: context.colors.onPrimary, size: 32),
    );
  }
}
