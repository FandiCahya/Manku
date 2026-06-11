import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class TransactionNudge extends StatelessWidget {
  final String message;
  final String? mascotEmoji;

  const TransactionNudge({
    super.key,
    this.message = "Don't forget your receipt for the coffee! ☕",
    this.mascotEmoji = '😊',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
                border: Border(
                  left: BorderSide(color: context.colors.primary, width: 4),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.colors.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: Text(
                mascotEmoji ?? '😊',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
