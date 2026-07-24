import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../models/transaction_api.dart';
import '../../../../widgets/assistant_section.dart';
import '../../../../widgets/search_bar_section.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../savings/presentation/cubit/savings_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_state.dart';
import '../../../../widgets/transaction_input_form.dart';
import 'error_banner.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', '30 Days', '7 Days', '3 Days'];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSubmitSuccess) {
          AppDialogs.showToast(
            context,
            message: state.message,
          );
          // Refresh dashboard & savings so home page stats stay up-to-date
          context.read<DashboardCubit>().fetchSummary();
          context.read<SavingsCubit>().fetchSavingsData();
        } else if (state is TransactionError) {
          AppDialogs.showToast(
            context,
            message: state.error,
            isSuccess: false,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TransactionLoading || state is TransactionInitial || state is TransactionSubmitting;
        final error = state is TransactionError ? state.error : null;

        List<TransactionGroup> filteredGroups = [];
        if (state is TransactionLoaded) {
          
          if (_selectedFilter == 'All') {
            filteredGroups = state.filteredGroups;
          } else {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final maxDays = _selectedFilter == '30 Days'
                ? 30
                : _selectedFilter == '7 Days'
                    ? 7
                    : 3;

            for (final group in state.filteredGroups) {
              DateTime? groupDate;
              try {
                // assume group.date is YYYY-MM-DD
                groupDate = DateTime.parse(group.date);
                groupDate = DateTime(groupDate.year, groupDate.month, groupDate.day);
              } catch (_) {}

              if (groupDate != null) {
                final diff = today.difference(groupDate).inDays;
                // Include if diff is within maxDays (and not far in the future, though future is fine)
                if (diff <= maxDays) {
                  filteredGroups.add(group);
                }
              } else {
                filteredGroups.add(group);
              }
            }
          }
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<TransactionCubit>().fetchTransactionsAndReport(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverToBoxAdapter(
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
                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _filters.map((filter) {
                              final isSelected = _selectedFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    filter,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedFilter = filter;
                                      });
                                    }
                                  },
                                  selectedColor: context.colors.primary.withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected ? context.colors.primary : context.colors.onSurfaceVariant,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected ? context.colors.primary : context.colors.outlineVariant,
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!isLoading && state is TransactionLoaded)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Menampilkan ${filteredGroups.fold<int>(0, (sum, g) => sum + g.transactions.length)} transaksi',
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
                          const EmptyHistoryWidget(),
                      ],
                    ),
                  ),
                ),
                if (!isLoading && error == null && filteredGroups.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == filteredGroups.length) {
                            return const SizedBox(height: 32);
                          }
                          return TransactionGroupWidget(group: filteredGroups[index]);
                        },
                        childCount: filteredGroups.length + 1,
                      ),
                    ),
                  ),
              ],
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
        ...group.transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final txn = entry.value;
          return SlideInLeft(
            delay: Duration(milliseconds: 100 + (index * 50)),
            child: TransactionItemWidget(txn: txn, date: group.date),
          );
        }),
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



  @override
  Widget build(BuildContext context) {
    final isIncome = txn.isIncome;
    final icon = _iconForCategory(txn.categoryName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Gamified colors
    final bgColor = isIncome ? context.colors.mint.withValues(alpha: 0.15) : context.colors.coral.withValues(alpha: 0.15);
    final iconColor = isIncome ? context.colors.mint : context.colors.coral;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  txn.categoryName,
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
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              final action = await AppDialogs.showActionSheet(context);
              if (!context.mounted) return;
              if (action == 'edit') {
                _showEditSheet(context);
              } else if (action == 'delete') {
                unawaited(_confirmDelete(context));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.more_horiz_rounded,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.grey.shade500,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    unawaited(showModalBottomSheet<void>(
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
    ));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      title: 'Hapus Transaksi?',
      message: 'Transaksi "${txn.description}" akan dihapus secara permanen dan tidak bisa dipulihkan.',
    );
    if ((confirmed ?? false) && context.mounted) {
      unawaited(context.read<TransactionCubit>().deleteTransaction(txn.id));
    }
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
