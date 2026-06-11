import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../profile/presentation/profile_page.dart';
import '../../savings/presentation/cubit/savings_cubit.dart';
import '../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../../widgets/transaction_input_form.dart';
import 'widgets/dashboard_tab.dart';
import 'widgets/history_tab.dart';
import 'widgets/reports_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentNavIndex = 0;
  late AnimationController _fabCtrl;
  late Animation<double> _fabAnim;

  @override
  void initState() {
    super.initState();
    _fetchAll();
    _fabCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150),
        lowerBound: 0.9, value: 1.0);
    _fabAnim = CurvedAnimation(parent: _ctrl(reversed: false), curve: Curves.easeInOut);
  }
  
  AnimationController _ctrl({required bool reversed}) => _fabCtrl;

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
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
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D3448) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: TransactionInputForm(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTapDown: (_) => _fabCtrl.reverse(),
        onTapUp: (_) {
          _fabCtrl.forward();
          _showAddSheet();
        },
        onTapCancel: () => _fabCtrl.forward(),
        child: ScaleTransition(
          scale: _fabCtrl,
          child: Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.only(top: 36),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C5F87) // Biru lebih gelap untuk dark mode
                  : context.colors.mint,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2C5F87)
                          : context.colors.mint)
                      .withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onItemSelected: (index) => setState(() => currentNavIndex = index),
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
