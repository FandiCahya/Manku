import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'nav_bar_item.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int currentIndex;
  final VoidCallback? onAddPressed;

  const BottomNavBar({
    required this.onItemSelected, 
    super.key,
    this.currentIndex = 0,
    this.onAddPressed,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SingleTickerProviderStateMixin {
  late int selectedIndex;
  late AnimationController _fabCtrl;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
    _fabCtrl = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9, 
      value: 1.0
    );
  }

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() => selectedIndex = widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: NavBarItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () {
                    setState(() => selectedIndex = 0);
                    widget.onItemSelected(0);
                  },
                ),
              ),
              Expanded(
                child: NavBarItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  isSelected: selectedIndex == 1,
                  onTap: () {
                    setState(() => selectedIndex = 1);
                    widget.onItemSelected(1);
                  },
                ),
              ),
              // Center item - Add Transaction
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => _fabCtrl.reverse(),
                  onTapUp: (_) {
                    _fabCtrl.forward();
                    widget.onAddPressed?.call();
                  },
                  onTapCancel: () => _fabCtrl.forward(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _fabCtrl,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C5F87)
                                : context.colors.mint,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isDark
                                        ? const Color(0xFF2C5F87)
                                        : context.colors.mint)
                                    .withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: isDark ? Colors.white : context.colors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: NavBarItem(
                  icon: Icons.analytics_rounded,
                  label: 'Reports',
                  isSelected: selectedIndex == 2,
                  onTap: () {
                    setState(() => selectedIndex = 2);
                    widget.onItemSelected(2);
                  },
                ),
              ),
              Expanded(
                child: NavBarItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: selectedIndex == 3,
                  onTap: () {
                    setState(() => selectedIndex = 3);
                    widget.onItemSelected(3);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
