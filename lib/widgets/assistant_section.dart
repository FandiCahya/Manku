import 'package:flutter/material.dart';

class AssistantSection extends StatelessWidget {
  const AssistantSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '"Found it! Looking for something specific?"',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.blue.shade900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.amber.shade200,
            child: const Icon(Icons.pets, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
