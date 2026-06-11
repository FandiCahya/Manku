import 'package:flutter/material.dart';
import '../widgets/components/app_header.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<TransactionModel> todayTransactions = [
    TransactionModel(
      title: 'Morning Brew Cafe',
      time: '10:45 AM • Dining',
      amount: -4.50,
      type: 'DEBIT',
      iconData: Icons.coffee,
      backgroundColor: Colors.pink.shade50,
      iconColor: Colors.pink,
    ),
    TransactionModel(
      title: 'Weekly Allowance',
      time: '09:00 AM • Income',
      amount: 50.00,
      type: 'DEPOSIT',
      iconData: Icons.account_balance_wallet,
      backgroundColor: Colors.yellow.shade50,
      iconColor: Colors.orange,
    ),
  ];

  final List<TransactionModel> yesterdayTransactions = [
    TransactionModel(
      title: 'Super Saver Market',
      time: '06:20 PM • Groceries',
      amount: -32.80,
      type: 'DEBIT',
      iconData: Icons.shopping_bag,
      backgroundColor: Colors.blue.shade50,
      iconColor: Colors.blue,
    ),
    TransactionModel(
      title: 'Cineplex 12',
      time: '08:00 PM • Entertainment',
      amount: -15.00,
      type: 'DEBIT',
      iconData: Icons.movie,
      backgroundColor: Colors.pink.shade50,
      iconColor: Colors.pink.shade300,
    ),
    TransactionModel(
      title: 'Cashback Reward',
      time: '12:30 PM • Bonus',
      amount: 1.25,
      type: 'GIFT',
      iconData: Icons.card_giftcard,
      backgroundColor: Colors.green.shade50,
      iconColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB), // Warna latar belakang
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBackground: false),
              const SizedBox(height: 16),
              const AssistantSection(),
              const SizedBox(height: 16),
              const SearchBarSection(),
              const SizedBox(height: 24),
              TransactionSection(
                dateTitle: 'TODAY, OCT 24',
                transactions: todayTransactions,
              ),
              const SizedBox(height: 16),
              TransactionSection(
                dateTitle: 'YESTERDAY, OCT 23',
                transactions: yesterdayTransactions,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

// ==========================================
// MODELS & DATA
// ==========================================
class TransactionModel {
  final String title;
  final String time;
  final double amount;
  final String type;
  final IconData iconData;
  final Color backgroundColor;
  final Color iconColor;

  TransactionModel({
    required this.title,
    required this.time,
    required this.amount,
    required this.type,
    required this.iconData,
    required this.backgroundColor,
    required this.iconColor,
  });
}

// ==========================================
// WIDGETS
// ==========================================

class AssistantSection extends StatelessWidget {
  const AssistantSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                color: Colors.blue.shade900,
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

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search activities...',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0D1B2A)),
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

class TransactionSection extends StatelessWidget {
  final String dateTitle;
  final List<TransactionModel> transactions;

  const TransactionSection({
    super.key,
    required this.dateTitle,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C5B72),
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        ...transactions.map((tx) => TransactionItem(transaction: tx)).toList(),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = transaction.amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: transaction.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(transaction.iconData, color: transaction.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.time,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}Rp ${transaction.amount.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isPositive ? Colors.green : const Color(0xFFC93B2B),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                transaction.type,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'DASHBOARD', false),
          _buildNavItem(Icons.history, 'HISTORY', true),
          _buildNavItem(Icons.add_circle, 'ADD', false, isSpecial: true),
          _buildNavItem(Icons.bar_chart, 'REPORTS', false),
          _buildNavItem(Icons.person, 'PROFILE', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected, {
    bool isSpecial = false,
  }) {
    Color selectedColor = Colors.blue.shade300;
    Color unselectedColor = Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSpecial
              ? Colors.blue
              : (isSelected ? selectedColor : unselectedColor),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: isSpecial
                ? Colors.blue
                : (isSelected ? selectedColor : unselectedColor),
          ),
        ),
      ],
    );
  }
}
