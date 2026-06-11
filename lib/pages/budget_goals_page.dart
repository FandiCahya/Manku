import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/budget_goal.dart';
import '../services/savings_service.dart';

class BudgetGoalsPage extends StatefulWidget {
  BudgetGoalsPage({Key? key}) : super(key: key);

  @override
  State<BudgetGoalsPage> createState() => _BudgetGoalsPageState();
}

class _BudgetGoalsPageState extends State<BudgetGoalsPage>
    with SingleTickerProviderStateMixin {
  BudgetGoalsResponse? _data;
  bool _loading = true;
  String? _error;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _fetchData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await SavingsService.fetchBudgetGoals();
      if (mounted) {
        setState(() {
          _data = data;
          _loading = false;
        });
        _animController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _fmtCurrency(double v) {
    final neg = v < 0;
    final parts = v.abs().toStringAsFixed(0).split('');
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write('.');
      buf.write(parts[i]);
    }
    return '${neg ? '-' : ''}Rp ${buf.toString()}';
  }

  Color _warningColor(BudgetWarningLevel level) {
    switch (level) {
      case BudgetWarningLevel.safe:
        return Colors.green.shade600;
      case BudgetWarningLevel.warning:
        return Colors.orange.shade600;
      case BudgetWarningLevel.critical:
        return Colors.deepOrange.shade600;
      case BudgetWarningLevel.exceeded:
        return Colors.red.shade700;
    }
  }

  Color _warningBg(BudgetWarningLevel level) {
    switch (level) {
      case BudgetWarningLevel.safe:
        return Colors.green.shade50;
      case BudgetWarningLevel.warning:
        return Colors.orange.shade50;
      case BudgetWarningLevel.critical:
        return Colors.deepOrange.shade50;
      case BudgetWarningLevel.exceeded:
        return Colors.red.shade50;
    }
  }

  IconData _warningIcon(BudgetWarningLevel level) {
    switch (level) {
      case BudgetWarningLevel.safe:
        return Icons.check_circle_outline;
      case BudgetWarningLevel.warning:
        return Icons.warning_amber_outlined;
      case BudgetWarningLevel.critical:
        return Icons.error_outline;
      case BudgetWarningLevel.exceeded:
        return Icons.cancel_outlined;
    }
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    const map = <String, IconData>{
      'makanan': Icons.restaurant,
      'food': Icons.restaurant,
      'makan': Icons.restaurant,
      'minuman': Icons.local_cafe,
      'transportasi': Icons.directions_car,
      'transport': Icons.directions_car,
      'bensin': Icons.local_gas_station,
      'belanja': Icons.shopping_bag,
      'shopping': Icons.shopping_bag,
      'hiburan': Icons.celebration,
      'entertainment': Icons.celebration,
      'tagihan': Icons.receipt_long,
      'bills': Icons.receipt_long,
      'listrik': Icons.bolt,
      'internet': Icons.wifi,
      'kesehatan': Icons.health_and_safety,
      'health': Icons.health_and_safety,
      'gaji': Icons.payments,
      'salary': Icons.payments,
      'pendidikan': Icons.school,
      'education': Icons.school,
    };
    for (final key in map.keys) {
      if (lower.contains(key)) return map[key]!;
    }
    return Icons.account_balance_wallet_outlined;
  }

  // ─── Dialog: Set Budget ──────────────────────────────────────────────────────

  Future<void> _showSetBudgetDialog({BudgetGoalItem? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.categoryName ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? existing.budgetAmount.toStringAsFixed(0) : '',
    );
    final isEditing = existing != null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              isEditing ? 'Edit Budget' : 'Set Budget Baru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            SizedBox(height: 6),
            Text(
              isEditing
                  ? 'Update budget untuk kategori "${existing.categoryName}"'
                  : 'Tentukan batas pengeluaran per kategori',
              style: TextStyle(fontSize: 13, color: context.colors.onSurfaceVariant),
            ),
            SizedBox(height: 24),
            // Category name (disabled jika editing)
            TextField(
              controller: nameCtrl,
              enabled: !isEditing,
              decoration: InputDecoration(
                hintText: 'Nama Kategori (contoh: Makanan)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.category_outlined,
                    color: context.colors.primary, size: 20),
                filled: true,
                fillColor: isEditing
                    ? context.colors.surfaceContainerHighest.withOpacity(0.4)
                    : context.colors.surfaceContainerLow,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: context.colors.outlineVariant.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 14),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Jumlah Budget (Rp)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                    color: context.colors.primary, size: 20),
                filled: true,
                fillColor: context.colors.surfaceContainerLow,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: context.colors.outlineVariant.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Info chip: bulan ini
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: context.colors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Budget berlaku untuk bulan ${_data?.month ?? 'ini'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final amount = double.tryParse(
                      amountCtrl.text.replaceAll('.', '').replaceAll(',', ''));
                  if ((name.isEmpty && !isEditing) ||
                      amount == null ||
                      amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Nama kategori & jumlah wajib diisi')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  try {
                    await SavingsService.setBudget(
                      categoryName: isEditing ? existing!.categoryName : name,
                      amount: amount,
                    );
                    _fetchData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Budget "${existing!.categoryName}" diperbarui!'
                                : 'Budget "$name" berhasil di-set!',
                          ),
                          backgroundColor: Colors.green.shade600,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Update Budget' : 'Set Budget',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BudgetGoalItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Budget?'),
        content: Text(
          'Budget untuk "${item.categoryName}" akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await SavingsService.deleteBudget(item.id);
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Budget "${item.categoryName}" dihapus'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        _buildHeader(),
                        SliverToBoxAdapter(child: _buildSummaryCard()),
                        SliverToBoxAdapter(child: _buildWarningsRow()),
                        SliverToBoxAdapter(child: _buildBudgetListHeader()),
                        if ((_data?.budgets ?? []).isEmpty)
                          SliverToBoxAdapter(child: _buildEmpty())
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 6),
                                child: _buildBudgetCard(_data!.budgets[i]),
                              ),
                              childCount: _data!.budgets.length,
                            ),
                          ),
                        SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: _loading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showSetBudgetDialog(),
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              icon: Icon(Icons.add),
              label: Text(
                'Set Budget',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 4,
            ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: context.colors.secondary,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.colors.secondary, context.colors.secondaryDim],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.account_balance_wallet,
                            color: Colors.white, size: 22),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget Goals',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            _data?.month ?? 'Bulan Ini',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _data!.summary;
    final pct = (summary.percentageUsed / 100).clamp(0.0, 1.0);
    final warnColor = _warningColor(summary.warningLevel);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [context.colors.secondary.withOpacity(0.9), context.colors.secondaryDim],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.colors.secondary.withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BUDGET',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _fmtCurrency(summary.totalBudget),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    summary.warningLevel.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terpakai: ${_fmtCurrency(summary.totalSpent)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${summary.percentageUsed.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      pct > 1.0
                          ? Colors.red.shade300
                          : pct >= 0.9
                              ? Colors.orange.shade300
                              : Colors.greenAccent.shade200,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sisa: ${_fmtCurrency(summary.totalRemaining)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsRow() {
    final summary = _data!.summary;
    if (summary.exceededCount == 0 && summary.warningCount == 0) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 18),
              SizedBox(width: 10),
              Text(
                'Semua budget dalam kondisi aman! 🎉',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          if (summary.exceededCount > 0) ...[
            Expanded(
              child: _warnChip(
                '${summary.exceededCount} melebihi batas',
                Icons.cancel_outlined,
                Colors.red.shade600,
                Colors.red.shade50,
              ),
            ),
          ],
          if (summary.exceededCount > 0 && summary.warningCount > 0)
            SizedBox(width: 12),
          if (summary.warningCount > 0)
            Expanded(
              child: _warnChip(
                '${summary.warningCount} mendekati batas',
                Icons.warning_amber_outlined,
                Colors.orange.shade700,
                Colors.orange.shade50,
              ),
            ),
        ],
      ),
    );
  }

  Widget _warnChip(String label, IconData icon, Color color, Color bg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetListHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Text(
            'Budget per Kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_data?.budgets.length ?? 0} kategori',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: context.colors.outlineVariant,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Belum Ada Budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan budget per kategori untuk\nmemantau pengeluaranmu!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetGoalItem item) {
    final warnColor = _warningColor(item.warningLevel);
    final warnBg = _warningBg(item.warningLevel);
    final warnIcon = _warningIcon(item.warningLevel);
    final pct = (item.percentageUsed / 100).clamp(0.0, 1.5);
    final isExceeded = item.warningLevel == BudgetWarningLevel.exceeded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isExceeded
            ? Border.all(color: Colors.red.shade200, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: isExceeded
                ? Colors.red.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: warnColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: warnBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconForCategory(item.categoryName),
                          color: warnColor, size: 22),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.categoryName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF13304f),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(warnIcon, size: 12, color: warnColor),
                              SizedBox(width: 4),
                              Text(
                                item.warningLevel.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: warnColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        if (val == 'edit') _showSetBudgetDialog(existing: item);
                        if (val == 'delete') _confirmDelete(item);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                            SizedBox(width: 10),
                            Text('Edit Budget'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            SizedBox(width: 10),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: warnColor.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(warnColor),
                  ),
                ),
                SizedBox(height: 10),
                // Amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _fmtCurrency(item.spentAmount),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: warnColor,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${_fmtCurrency(item.budgetAmount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: warnBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.percentageUsed.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: warnColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // Remaining
                Row(
                  children: [
                    Icon(
                      isExceeded
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 13,
                      color: isExceeded ? Colors.red.shade600 : Colors.green.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      isExceeded
                          ? 'Melebihi ${_fmtCurrency(item.spentAmount - item.budgetAmount)}'
                          : 'Sisa ${_fmtCurrency(item.remaining)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExceeded ? Colors.red.shade600 : Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
