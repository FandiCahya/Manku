import 'package:flutter/material.dart';

class SearchBarSection extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const SearchBarSection({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? const Color(0xFF253F55) 
          : Colors.blue.shade50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: 'Search activities...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey.shade600
          ),
          prefixIcon: Icon(
            Icons.search, 
            color: isDark ? Colors.white70 : const Color(0xFF0D1B2A)
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
