import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/dashboard_summary.dart';
import '../models/transaction_api.dart';
import '../models/report_summary.dart';
import '../services/transaction_service.dart';
import '../widgets/components/app_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/stats_grid.dart';
import '../widgets/spending_trends_chart.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/assistant_section.dart';
import '../widgets/search_bar_section.dart';
import '../widgets/spending_performance_chart.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/chat_transaction_input.dart';
import '../widgets/transaction_input_form.dart';
import 'profile_page.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentNavIndex = 0;

  // Mode toggle: true = Form Manual, false = Chat AI
  bool _isFormMode = true;

  // ── Data state ─────────────────────────────────────────────────────────
  DashboardSummary? _dashboard;
  TransactionHistory? _history;
  ReportSummary? _report;

  bool _dashboardLoading = true;
  bool _historyLoading = true;
  bool _reportLoading = true;

  String? _dashboardError;
  String? _historyError;
  String? _reportError;

  // ── Search query ───────────────────────────────────────────────────────
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    _fetchDashboard();
    _fetchHistory();
    _fetchReport();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _dashboardLoading = true;
      _dashboardError = null;
    });
    try {
      final data = await TransactionService.fetchDashboardSummary();
      if (mounted) setState(() { _dashboard = data; _dashboardLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _dashboardError = e.toString(); _dashboardLoading = false; });
    }
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _historyLoading = true;
      _historyError = null;
    });
    try {
      final data = await TransactionService.fetchHistory();
      if (mounted) setState(() { _history = data; _historyLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _historyError = e.toString(); _historyLoading = false; });
    }
  }

  Future<void> _fetchReport() async {
    setState(() {
      _reportLoading = true;
      _reportError = null;
    });
    try {
      final data = await TransactionService.fetchReportSummary();
      if (mounted) setState(() { _report = data; _reportLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _reportError = e.toString(); _reportLoading = false; });
    }
  }

  /// Dipanggil setelah transaksi baru berhasil disimpan
  void _onTransactionAdded() {
    _fetchDashboard();
    _fetchHistory();
    _fetchReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      extendBody: true, // content flows under the notched nav bar
      body: _buildContent(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onItemSelected: (index) {
          setState(() => currentNavIndex = index);
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (currentNavIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildHistoryContent();
      case 2:
        return _buildAddContent();
      case 3:
        return _buildReportsContent();
      case 4:
        return _buildProfileContent();
      default:
        return _buildDashboardContent();
    }
  }


  // ── DASHBOARD ──────────────────────────────────────────────────────────
  Widget _buildDashboardContent() {
    return Column(
      children: [
        AppHeader(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchDashboard,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24, bottom: 100),
              child: Column(
                spacing: 32,
                children: [
                  BalanceCard(
                    totalBalance: _dashboard?.totalBalance,
                    isLoading: _dashboardLoading,
                  ),
                  StatsGrid(
                    dailyExpense: _dashboard?.dailyExpense,
                    budgetLeft: _dashboard?.budgetLeft,
                    totalIncome: _dashboard?.totalIncome,
                    isLoading: _dashboardLoading,
                  ),
                  SpendingTrendsChart(
                    trends: _dashboard?.spendingTrends,
                    maxAmount: _dashboard?.maxTrendAmount ?? 1.0,
                    isLoading: _dashboardLoading,
                  ),
                  if (_dashboardError != null)
                    _buildErrorBanner(_dashboardError!, _fetchDashboard),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── HISTORY ────────────────────────────────────────────────────────────
  Widget _buildHistoryContent() {
    final groups = _history?.groups ?? [];

    // Filter berdasarkan search query
    final filteredGroups = _searchQuery.isEmpty
        ? groups
        : groups.map((g) {
            final filteredTxns = g.transactions.where((t) {
              final q = _searchQuery.toLowerCase();
              return t.description.toLowerCase().contains(q) ||
                  t.categoryName.toLowerCase().contains(q);
            }).toList();
            return filteredTxns.isEmpty
                ? null
                : TransactionGroup(
                    dateLabel: g.dateLabel,
                    date: g.date,
                    transactions: filteredTxns,
                  );
          }).whereType<TransactionGroup>().toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(showBackground: false),
              SizedBox(height: 16),
              AssistantSection(),
              SizedBox(height: 16),
              SearchBarSection(
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
              SizedBox(height: 16),
              // Summary bar
              if (!_historyLoading && _history != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${_history!.totalTransactions} transaksi total',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (_historyLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_historyError != null)
                _buildErrorBanner(_historyError!, _fetchHistory)
              else if (filteredGroups.isEmpty)
                _buildEmptyHistory()
              else
                ...filteredGroups.map((group) => _buildTransactionGroup(group)),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionGroup(TransactionGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            group.dateLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C5B72),
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...group.transactions.map((txn) => _buildTransactionItem(txn)),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTransactionItem(ApiTransaction txn) {
    final isIncome = txn.isIncome;
    final icon = _iconForCategory(txn.categoryName);
    final bgColor = isIncome
        ? Colors.green.shade50
        : _bgColorForCategory(txn.categoryName);
    final iconColor = isIncome ? Colors.green : _iconColorForCategory(txn.categoryName);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0D1B2A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${txn.time} • ${txn.categoryName}',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIncome ? Colors.green : Color(0xFFC93B2B),
                ),
              ),
              SizedBox(height: 3),
              Text(
                isIncome ? 'INCOME' : 'EXPENSE',
                style: TextStyle(
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

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: context.colors.outlineVariant),
            SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tambahkan transaksi pertama kamu\ndi menu Add',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ADD TRANSACTION ─────────────────────────────────────────────────────
  Widget _buildAddContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildAddHeader(),
          Divider(height: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _isFormMode
                  ? TransactionInputForm(
                      key: ValueKey('form'),
                      onTransactionSaved: _onTransactionAdded,
                    )
                  : ChatTransactionInput(
                      key: ValueKey('chat'),
                      onTransactionSaved: _onTransactionAdded,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isFormMode ? 'Form Manual' : 'Chat AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.secondary,
                ),
              ),
              Text(
                _isFormMode
                    ? 'Isi data transaksi secara manual'
                    : 'Ceritakan transaksimu dengan teks',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () => setState(() => _isFormMode = !_isFormMode),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isFormMode
                    ? context.colors.primaryContainer
                    : context.colors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isFormMode
                            ? context.colors.primary
                            : context.colors.secondary)
                        .withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isFormMode ? Icons.chat_bubble_outline : Icons.edit_note,
                    size: 16,
                    color: _isFormMode
                        ? context.colors.onPrimaryContainer
                        : context.colors.onSecondaryContainer,
                  ),
                  SizedBox(width: 6),
                  Text(
                    _isFormMode ? 'Chat AI' : 'Form Manual',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _isFormMode
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── REPORTS ─────────────────────────────────────────────────────────────
  Widget _buildReportsContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchReport,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            spacing: 24,
            children: [
              SpendingPerformanceChart(
                report: _report,
                isLoading: _reportLoading,
              ),
              CategoryBreakdown(
                categories: _report?.categoryBreakdown,
                isLoading: _reportLoading,
              ),
              if (_reportError != null)
                _buildErrorBanner(_reportError!, _fetchReport),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────
  Color _getBackgroundColor() => context.colors.background;

  Widget _buildProfileContent() => ProfilePage();


  Widget _buildErrorBanner(String error, VoidCallback onRetry) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gagal memuat data. Periksa koneksi.',
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Icon & color helpers untuk history
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

  Color _bgColorForCategory(String name) {
    final idx = name.hashCode.abs() % _bgPalette.length;
    return _bgPalette[idx];
  }

  Color _iconColorForCategory(String name) {
    final idx = name.hashCode.abs() % _iconPalette.length;
    return _iconPalette[idx];
  }
}
