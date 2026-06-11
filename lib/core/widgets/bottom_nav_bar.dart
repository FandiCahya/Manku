import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'nav_bar_item.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int currentIndex;

  const BottomNavBar({
    required this.onItemSelected, super.key,
    this.currentIndex = 0,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() => selectedIndex = widget.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Empty space for the FAB
              const SizedBox(width: 72),
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
