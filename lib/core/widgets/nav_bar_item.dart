import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isProminent ? 16 : 12),
        decoration: BoxDecoration(
          color: isProminent
              ? const Color(0xFF42A5F5)
              : (isSelected ? context.colors.primaryContainer : Colors.transparent),
          shape: isProminent ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isProminent ? null : BorderRadius.circular(24),
          boxShadow: isProminent
              ? [
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isProminent
                  ? Colors.white
                  : (isSelected ? context.colors.primary : context.colors.secondary),
              size: isProminent ? 28 : 24,
            ),
            if (!isProminent) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? context.colors.primary : context.colors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
