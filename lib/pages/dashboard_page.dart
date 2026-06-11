import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/components/app_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/stats_grid.dart';
import '../widgets/spending_trends_chart.dart';
import '../widgets/bottom_nav_bar.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          // App Header
          AppHeader(),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                spacing: 32,
                children: [
                  // Balance Card
                  BalanceCard(),
                  // Stats Grid
                  StatsGrid(),
                  // Spending Trends Chart
                  SpendingTrendsChart(),
                  // Extra spacing for bottom nav
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onItemSelected: (index) {
          setState(() => currentNavIndex = index);
          // Handle navigation based on index
          _handleNavigation(index);
        },
      ),
    );
  }

  void _handleNavigation(int index) {
    String message = '';
    switch (index) {
      case 0:
        message = 'Dashboard';
        break;
      case 1:
        message = 'History';
        break;
      case 2:
        message = 'Add';
        break;
      case 3:
        message = 'Reports';
        break;
      case 4:
        message = 'Profile';
        break;
    }
  }
}
