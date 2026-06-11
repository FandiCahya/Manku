import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../profile/presentation/profile_page.dart';
import '../../savings/presentation/cubit/savings_cubit.dart';
import '../../transactions/presentation/cubit/transaction_cubit.dart';
import 'widgets/add_transaction_tab.dart';
import 'widgets/dashboard_tab.dart';
import 'widgets/history_tab.dart';
import 'widgets/reports_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  void _fetchAll() {
    context.read<DashboardCubit>().fetchSummary();
    context.read<TransactionCubit>().fetchTransactionsAndReport();
  }

  void _onTransactionAdded() {
    context.read<DashboardCubit>().fetchSummary();
    context.read<SavingsCubit>().fetchSavingsData();
  }

  void _showAddSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.black87 : Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<TransactionCubit>(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D3448) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: AddTransactionTab(
              onTransactionSaved: () {
                Navigator.pop(context);
                _onTransactionAdded();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: _buildContent(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onItemSelected: (index) => setState(() => currentNavIndex = index),
        onAddPressed: _showAddSheet,
      ),
    );
  }

  Widget _buildContent() {
    switch (currentNavIndex) {
      case 0:
        return const DashboardTab();
      case 1:
        return const HistoryTab();
      case 2:
        return const ReportsTab();
      case 3:
        return const ProfilePage();
      default:
        return const DashboardTab();
    }
  }
}
