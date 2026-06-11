import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class QuickActionButtons extends StatelessWidget {
  final Function()? onScanReceipt;
  final Function()? onSpeak;
  final Function()? onManual;

  const QuickActionButtons({
    super.key,
    this.onScanReceipt,
    this.onSpeak,
    this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'How are we adding today?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.colors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 280,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.photo_camera,
                label: 'Scan Receipt',
                onPressed: onScanReceipt,
              ),
              _buildActionButton(
                context: context,
                icon: Icons.mic,
                label: 'Speak to Add',
                isHighlight: true,
                onPressed: onSpeak,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isHighlight = false,
    VoidCallback? onPressed,
  }) {
    if (isHighlight) {
      return GestureDetector(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulse animation background
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: context.colors.secondaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                // Main button
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: context.colors.onPrimary, size: 40),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: context.colors.onPrimary, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
