import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../models/transaction_api.dart';
import '../../../../widgets/assistant_section.dart';
import '../../../../widgets/search_bar_section.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../savings/presentation/cubit/savings_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_state.dart';
import '../../../../widgets/transaction_input_form.dart';
import 'error_banner.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(state.message),
                ],
              ),
              backgroundColor: context.colors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          // Refresh dashboard & savings so home page stats stay up-to-date
          context.read<DashboardCubit>().fetchSummary();
          context.read<SavingsCubit>().fetchSavingsData();
        } else if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: context.colors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TransactionLoading || state is TransactionInitial || state is TransactionSubmitting;
        final error = state is TransactionError ? state.error : null;

        int totalTxns = 0;
        List<TransactionGroup> filteredGroups = [];
        if (state is TransactionLoaded) {
          totalTxns = state.history.totalTransactions;
          filteredGroups = state.filteredGroups;
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<TransactionCubit>().fetchTransactionsAndReport(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(showBackground: false),
                  const SizedBox(height: 16),
                  const AssistantSection(),
                  const SizedBox(height: 16),
                  SearchBarSection(
                    onChanged: (q) => context.read<TransactionCubit>().searchTransactions(q),
                  ),
                  const SizedBox(height: 16),
                  if (!isLoading && state is TransactionLoaded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '$totalTxns transaksi total',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (error != null)
                    ErrorBanner(
                      error: error,
                      onRetry: () => context.read<TransactionCubit>().fetchTransactionsAndReport(),
                    )
                  else if (filteredGroups.isEmpty)
                    const EmptyHistoryWidget()
                  else
                    ...filteredGroups.map((group) => TransactionGroupWidget(group: group)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TransactionGroupWidget extends StatelessWidget {
  const TransactionGroupWidget({
    required this.group,
    super.key,
  });

  final TransactionGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            group.dateLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C5B72),
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...group.transactions.map((txn) => TransactionItemWidget(txn: txn, date: group.date)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class TransactionItemWidget extends StatelessWidget {
  const TransactionItemWidget({
    required this.txn,
    required this.date,
    super.key,
  });

  final ApiTransaction txn;
  final String date;

  static const Map<String, IconData> _catIcons = {
    'makanan': Icons.restaurant,
    'food': Icons.restaurant,
    'minuman': Icons.local_cafe,
    'transportasi': Icons.directions_car,
    'transport': Icons.directions_car,
    'belanja': Icons.shopping_bag,
    'shopping': Icons.shopping_bag,
    'hiburan': Icons.celebration,
    'entertainment': Icons.celebration,
    'tagihan': Icons.receipt_long,
    'bills': Icons.receipt_long,
    'kesehatan': Icons.health_and_safety,
    'health': Icons.health_and_safety,
    'gaji': Icons.payments,
    'salary': Icons.payments,
    'pendidikan': Icons.school,
  };

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    for (final key in _catIcons.keys) {
      if (lower.contains(key)) return _catIcons[key]!;
    }
    return Icons.category;
  }

  static const List<Color> _bgPalette = [
    Color(0xFFfce4ec),
    Color(0xFFe3f2fd),
    Color(0xFFe8f5e9),
    Color(0xFFfff8e1),
    Color(0xFFede7f6),
    Color(0xFFfbe9e7),
  ];
  static const List<Color> _iconPalette = [
    Color(0xFFe91e63),
    Color(0xFF1e88e5),
    Color(0xFF43a047),
    Color(0xFFffa000),
    Color(0xFF7b1fa2),
    Color(0xFFe64a19),
  ];

  Color _bgColorForCategory(String name) =>
      _bgPalette[name.hashCode.abs() % _bgPalette.length];

  Color _iconColorForCategory(String name) =>
      _iconPalette[name.hashCode.abs() % _iconPalette.length];

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.isIncome;
    final icon = _iconForCategory(txn.categoryName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Gamified colors
    final bgColor = isIncome ? context.colors.mint.withOpacity(0.15) : context.colors.coral.withOpacity(0.15);
    final iconColor = isIncome ? context.colors.mint : context.colors.coral;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isDark ? Colors.white : context.colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${txn.time} • ${txn.categoryName}',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}Rp ${txn.amount.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]}.',
                    )}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isIncome ? context.colors.mint : context.colors.coral,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isIncome ? 'INCOME' : 'EXPENSE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditSheet(context);
              } else if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<TransactionCubit>(),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D3448) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: TransactionInputForm(
              existing: txn,
              existingDate: date,
              onTransactionSaved: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text('Transaksi ini akan dihapus permanen.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TransactionCubit>().deleteTransaction(txn.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: context.colors.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan transaksi pertama kamu\ndi menu Add',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
