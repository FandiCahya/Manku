import 'package:flutter/material.dart';
import '../../core/constants/colors.dart'; 

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label; // Kept for semantics, not displayed
  final bool isSelected;
  final VoidCallback onTap;
  final bool isProminent;

  const NavBarItem({
    required this.icon, required this.label, required this.isSelected, required this.onTap, super.key,
    this.isProminent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.lavender : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.lavender.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? Colors.white : const Color(0xFF858997), // Soft grey for inactive
            size: isSelected ? 24 : 22,
          ),
        ),
      ),
    );
  }
}
