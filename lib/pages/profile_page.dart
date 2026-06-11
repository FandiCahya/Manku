import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants/colors.dart';
import '../models/budget_goal.dart';
import '../services/savings_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // ─── User info ────────────────────────────────────────────────────────────
  bool isDarkMode = false;
  String userName = 'User';
  String userEmail = '';
  String? userPhotoUrl;

  // ─── Tab controller ───────────────────────────────────────────────────────
  late TabController _tabController;

  // ─── Budget data ──────────────────────────────────────────────────────────
  BudgetGoalsResponse? _budgetData;
  bool _budgetLoading = true;
  String? _budgetError;

  // ─── Financial Advice data ───────────────────────────────────────────────
  Map<String, dynamic>? _adviceData;
  bool _adviceLoading = true;
  String? _adviceError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
    _fetchBudget();
    _fetchAdvice();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Data Fetching ────────────────────────────────────────────────────────

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userName = prefs.getString('user_name') ?? 'User';
        userEmail = prefs.getString('user_email') ?? '';
        userPhotoUrl = prefs.getString('user_photo');
      });
    }
  }

  Future<void> _fetchBudget() async {
    setState(() {
      _budgetLoading = true;
      _budgetError = null;
    });
    try {
      final data = await SavingsService.fetchBudgetGoals();
      if (mounted) setState(() { _budgetData = data; _budgetLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _budgetError = e.toString(); _budgetLoading = false; });
    }
  }

  Future<void> _fetchAdvice() async {
    setState(() {
      _adviceLoading = true;
      _adviceError = null;
    });
    try {
      final data = await SavingsService.fetchFinancialAdvice();
      if (mounted) {
        setState(() {
          _adviceData = data;
          _adviceLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _adviceError = e.toString();
          _adviceLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Google sign out error: $e');
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

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



  Color _warningColor(BudgetWarningLevel lvl) {
    switch (lvl) {
      case BudgetWarningLevel.safe:     return Colors.green.shade600;
      case BudgetWarningLevel.warning:  return Colors.orange.shade600;
      case BudgetWarningLevel.critical: return Colors.deepOrange.shade600;
      case BudgetWarningLevel.exceeded: return Colors.red.shade700;
    }
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    const map = <String, IconData>{
      'makanan': Icons.restaurant, 'makan': Icons.restaurant,
      'food': Icons.restaurant, 'minuman': Icons.local_cafe,
      'transportasi': Icons.directions_car, 'transport': Icons.directions_car,
      'bensin': Icons.local_gas_station, 'belanja': Icons.shopping_bag,
      'shopping': Icons.shopping_bag, 'hiburan': Icons.celebration,
      'entertainment': Icons.celebration, 'tagihan': Icons.receipt_long,
      'bills': Icons.receipt_long, 'listrik': Icons.bolt,
      'internet': Icons.wifi, 'kesehatan': Icons.health_and_safety,
      'health': Icons.health_and_safety, 'gaji': Icons.payments,
      'salary': Icons.payments, 'pendidikan': Icons.school,
    };
    for (final key in map.keys) {
      if (lower.contains(key)) return map[key]!;
    }
    return Icons.account_balance_wallet_outlined;
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────



  Future<void> _showSetBudgetDialog({BudgetGoalItem? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.categoryName ?? '');
    final amountCtrl = TextEditingController(text: existing != null ? existing.budgetAmount.toStringAsFixed(0) : '');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _sheetWrapper(
        ctx: ctx,
        title: existing != null ? 'Edit Budget' : 'Set Budget Baru',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(nameCtrl, 'Nama Kategori', Icons.category_outlined, enabled: existing == null),
          SizedBox(height: 12),
          _field(amountCtrl, 'Jumlah Budget (Rp)', Icons.account_balance_wallet_outlined, type: TextInputType.number),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: context.colors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.info_outline, size: 16, color: context.colors.primary),
              SizedBox(width: 8),
              Text('Budget berlaku untuk bulan ${_budgetData?.month ?? 'ini'}',
                  style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
            ]),
          ),
          SizedBox(height: 24),
          _primaryButton(
            label: existing != null ? 'Update Budget' : 'Set Budget',
            color: context.colors.secondary,
            onTap: () async {
              final name = nameCtrl.text.trim();
              final amount = double.tryParse(amountCtrl.text.replaceAll('.', '').replaceAll(',', ''));
              if ((name.isEmpty && existing == null) || amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nama & jumlah wajib diisi')));
                return;
              }
              Navigator.pop(ctx);
              try {
                await SavingsService.setBudget(
                  categoryName: existing != null ? existing.categoryName : name,
                  amount: amount,
                );
                _fetchBudget();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget berhasil ${existing != null ? 'diupdate' : 'dibuat'}!'),
                      backgroundColor: Colors.green.shade600));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
          ),
        ]),
      ),
    );
  }



  Future<void> _confirmDeleteBudget(BudgetGoalItem item) async {
    final ok = await _confirmDialog('Hapus Budget?', 'Budget "${item.categoryName}" akan dihapus.');
    if (ok) {
      try {
        await SavingsService.deleteBudget(item.id);
        _fetchBudget();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${item.categoryName}" dihapus'), backgroundColor: Colors.red.shade600));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  Future<bool> _confirmDialog(String title, String msg) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ─── Shared Widget Builders ───────────────────────────────────────────────

  Widget _sheetWrapper({required BuildContext ctx, required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        top: 20, left: 24, right: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
          SizedBox(height: 20),
          child,
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text, bool enabled = true}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: context.colors.primary, size: 20),
        filled: true,
        fillColor: enabled ? context.colors.surfaceContainerLow : context.colors.surfaceContainerHighest.withOpacity(0.4),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.outlineVariant.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.primary, width: 1.5)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _primaryButton({required String label, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ─── Main Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          _buildHeader(),
          // Tab bar
          Container(
            color: context.colors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: context.colors.primary,
              labelColor: context.colors.primary,
              unselectedLabelColor: context.colors.onSurfaceVariant,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: '👤 Profil'),
                Tab(text: '📊 Pengelolaan Keuangan'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildBudgetTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header (shared across tabs) ─────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.primary, context.colors.primaryDim],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.onPrimary,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: userPhotoUrl != null
                      ? Image.network(userPhotoUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.person, size: 40, color: context.colors.primary))
                      : Icon(Icons.person, size: 40, color: context.colors.primary),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3)),
                    if (userEmail.isNotEmpty)
                      Text(userEmail, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.75)), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Logout icon
              IconButton(
                icon: Icon(Icons.logout_outlined, color: Colors.white),
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Logout?'),
                    content: Text('Kamu akan keluar dari akun ini.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal')),
                      ElevatedButton(
                        onPressed: () { Navigator.pop(ctx); _handleLogout(); },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab 0: Profile ───────────────────────────────────────────────────────

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Settings
          _sectionTitle('Pengaturan'),
          SizedBox(height: 12),
          _settingItem('Pengaturan Akun', Icons.security, context.colors.primary, () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pengaturan Akun')));
          }),
          SizedBox(height: 10),
          // Dark mode toggle
          _settingToggle('App Theme', Icons.palette, Color(0xFF42A5F5)),
          SizedBox(height: 10),
          _settingItem('Notifikasi', Icons.notifications_outlined, Colors.orange, () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notifikasi')));
          }),
          SizedBox(height: 10),
          _settingItem('Tentang Aplikasi', Icons.info_outline, Colors.teal, () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ManKu v1.0.0')));
          }),
          SizedBox(height: 32),
          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('Logout?'),
                  content: Text('Kamu akan keluar dari akun ini.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); _handleLogout(); },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface));
  }

  Widget _settingItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 2))]),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: context.colors.outlineVariant),
        onTap: onTap,
      ),
    );
  }

  Widget _settingToggle(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 2))]),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text('App Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: Switch(
          value: isDarkMode,
          activeColor: context.colors.primary,
          onChanged: (val) => setState(() => isDarkMode = val),
        ),
      ),
    );
  }



  // ─── Tab 2: Budget ────────────────────────────────────────────────────────

  Widget _buildBudgetTab() {
    if (_budgetLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_budgetError != null) {
      return _errorWidget(_budgetError!, _fetchBudget);
    }
    final bd = _budgetData!;
    final summary = bd.summary;
    final pct = (summary.percentageUsed / 100).clamp(0.0, 1.0);

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchBudget();
        await _fetchAdvice();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [context.colors.secondary, context.colors.secondaryDim],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: context.colors.secondary.withOpacity(0.3), blurRadius: 16, offset: Offset(0, 6))],
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('TOTAL BUDGET — ${bd.month}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    SizedBox(height: 6),
                    Text(_fmtCurrency(summary.totalBudget), style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  ]),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(summary.warningLevel.label, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ]),
                SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Terpakai: ${_fmtCurrency(summary.totalSpent)}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  Text('${summary.percentageUsed.toStringAsFixed(1)}%', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ]),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct, minHeight: 9,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      pct > 1.0 ? Colors.red.shade300 : pct >= 0.9 ? Colors.orange.shade300 : Colors.greenAccent.shade200),
                  ),
                ),
                SizedBox(height: 8),
                Text('Sisa: ${_fmtCurrency(summary.totalRemaining)}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ]),
            ),
            SizedBox(height: 16),

            // Warning chips
            if (summary.exceededCount > 0 || summary.warningCount > 0)
              Row(children: [
                if (summary.exceededCount > 0) Expanded(child: _warnChip('${summary.exceededCount} melewati batas', Icons.cancel_outlined, Colors.red.shade600, Colors.red.shade50)),
                if (summary.exceededCount > 0 && summary.warningCount > 0) SizedBox(width: 10),
                if (summary.warningCount > 0) Expanded(child: _warnChip('${summary.warningCount} mendekati batas', Icons.warning_amber_outlined, Colors.orange.shade700, Colors.orange.shade50)),
              ])
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                child: Row(children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
                  SizedBox(width: 8),
                  Text('Semua budget aman! 🎉', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              ),

            // AI Financial Advice Card
            _buildFinancialAdviceCard(),
            SizedBox(height: 24),

            // List header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Per Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
              TextButton.icon(
                onPressed: () => _showSetBudgetDialog(),
                icon: Icon(Icons.add, size: 16),
                label: Text('Set Budget', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(foregroundColor: context.colors.secondary),
              ),
            ]),
            SizedBox(height: 8),

            if (bd.budgets.isEmpty) _emptyState('Belum ada budget', 'Tap "Set Budget" untuk menambah budget per kategori.', Icons.account_balance_wallet_outlined),
            ...bd.budgets.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _budgetCard(item),
            )),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialAdviceCard() {
    if (_adviceLoading) {
      return Container(
        margin: EdgeInsets.only(top: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(context.colors.primary),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Menganalisis keuangan dengan AI...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_adviceError != null) {
      return Container(
        margin: EdgeInsets.only(top: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                SizedBox(width: 8),
                Text(
                  'Gagal memuat saran AI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              _adviceError!,
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchAdvice,
              icon: Icon(Icons.refresh, size: 16),
              label: Text('Coba Lagi', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }

    if (_adviceData == null) return SizedBox.shrink();

    final status = _adviceData!['status_keuangan'] ?? 'Belum Menganalisis';
    final ringkasan = _adviceData!['ringkasan_analisis'] ?? '';
    final tips = _adviceData!['tips_tambahan'] ?? '';
    final saranRaw = _adviceData!['saran_list'];
    final List<dynamic> saranList = saranRaw is List ? saranRaw : [];

    Color badgeBg;
    Color badgeText;
    switch (status.toString().toLowerCase()) {
      case 'sangat baik':
      case 'sehat':
        badgeBg = Colors.green.shade50;
        badgeText = Colors.green.shade700;
        break;
      case 'butuh penyesuaian':
        badgeBg = Colors.orange.shade50;
        badgeText = Colors.orange.shade700;
        break;
      case 'kritis':
        badgeBg = Colors.red.shade50;
        badgeText = Colors.red.shade700;
        break;
      default:
        badgeBg = context.colors.surfaceContainer;
        badgeText = context.colors.onSurfaceVariant;
    }

    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        color: context.colors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Saran AI Keuangan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _fetchAdvice,
                  child: Icon(
                    Icons.refresh_rounded,
                    color: context.colors.outline,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1),

          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Status Keuangan: $status',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeText,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                
                // Ringkasan
                Text(
                  ringkasan,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: context.colors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 16),

                // Saran List
                if (saranList.isNotEmpty) ...[
                  Text(
                    'Rekomendasi Utama:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...saranList.map((saran) => Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            color: context.colors.primary,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            saran.toString(),
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],

                // Tips Tambahan
                if (tips.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.outlineVariant.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          color: context.colors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tips,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _warnChip(String label, IconData icon, Color color, Color bg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 14),
        SizedBox(width: 6),
        Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11))),
      ]),
    );
  }

  Widget _budgetCard(BudgetGoalItem item) {
    final warnColor = _warningColor(item.warningLevel);
    final pct = (item.percentageUsed / 100).clamp(0.0, 1.0);
    final isExceeded = item.warningLevel == BudgetWarningLevel.exceeded;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: isExceeded ? Border.all(color: Colors.red.shade200, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(children: [
        Container(height: 3, decoration: BoxDecoration(color: warnColor, borderRadius: BorderRadius.vertical(top: Radius.circular(18)))),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: warnColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(_iconForCategory(item.categoryName), color: warnColor, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.categoryName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF13304f))),
                Text(item.warningLevel.label, style: TextStyle(fontSize: 11, color: warnColor, fontWeight: FontWeight.w600)),
              ])),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (val) {
                  if (val == 'edit') _showSetBudgetDialog(existing: item);
                  if (val == 'delete') _confirmDeleteBudget(item);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, color: Colors.blue, size: 16), SizedBox(width: 8), Text('Edit Budget')])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 16), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ]),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct, minHeight: 7,
                backgroundColor: warnColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation(warnColor),
              ),
            ),
            SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              RichText(text: TextSpan(children: [
                TextSpan(text: _fmtCurrency(item.spentAmount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: warnColor)),
                TextSpan(text: ' / ${_fmtCurrency(item.budgetAmount)}', style: TextStyle(fontSize: 11, color: context.colors.onSurfaceVariant)),
              ])),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: warnColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${item.percentageUsed.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: warnColor)),
              ),
            ]),
            SizedBox(height: 4),
            Row(children: [
              Icon(isExceeded ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 12, color: isExceeded ? Colors.red.shade600 : Colors.green.shade600),
              SizedBox(width: 4),
              Text(
                isExceeded ? 'Melebihi ${_fmtCurrency(item.spentAmount - item.budgetAmount)}' : 'Sisa ${_fmtCurrency(item.remaining)}',
                style: TextStyle(fontSize: 11, color: isExceeded ? Colors.red.shade600 : Colors.green.shade600, fontWeight: FontWeight.w600),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ─── Shared Utility Widgets ───────────────────────────────────────────────

  Widget _emptyState(String title, String subtitle, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Column(children: [
        Container(padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: context.colors.surfaceContainerLow, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: context.colors.outlineVariant)),
        SizedBox(height: 14),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
        SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
      ])),
    );
  }

  Widget _errorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text('Gagal memuat data', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
          SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 12)),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      ),
    );
  }
}
