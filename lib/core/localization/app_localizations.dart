import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'app_name': 'ManKu',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',
      
      // Navigation
      'nav_home': 'Home',
      'nav_history': 'History',
      'nav_add': 'Add',
      'nav_reports': 'Reports',
      'nav_profile': 'Profile',
      
      // Home - Balance Card
      'total_balance': 'Total Balance',
      'add_transaction': 'Add Transaction',
      
      // Home - Monthly Balance
      'monthly_balance': 'Monthly Balance',
      'balance': 'balance',
      'income': 'Income',
      'expense': 'Expense',
      'surplus': 'Surplus',
      'deficit': 'Deficit',
      
      // Home - Financial Goals
      'financial_goals': 'Financial Goals',
      'total_goals': 'Total Goals',
      'achieved': 'Achieved',
      'progress': 'Progress',
      'tap_to_view': 'Tap to view details',
      
      // Home - Stats
      'daily_expense': 'Daily Expense',
      
      // Home - Spending Performance
      'spending_performance': 'Spending Performance',
      'last_7_days': 'Last 7 Days',
      
      // Goals Page
      'budget_goals': 'Budget Goals',
      'long_term_savings': 'Long-term Savings',
      'total_target': 'TOTAL TARGET',
      'collected': 'Collected',
      'remaining': 'Remaining',
      'add_goal': 'Add Goal',
      'savings_goals': 'Savings Goals',
      'goals_count': 'goals',
      'no_goals_yet': 'No Goals Yet',
      'add_savings_goal': 'Add savings goal to\nachieve your dreams!',
      'delete_goal': 'Delete Goal?',
      'goal_will_be_deleted': 'Goal "{name}" will be deleted.',
      
      // Goal Status
      'safe': 'Safe',
      'approaching_target': 'Approaching Target',
      'almost_achieved': 'Almost Achieved',
      'target_achieved': 'Target Achieved!',
      'target_reached': 'Target reached! 🎉',
      'need_more': 'Need {amount} more',
      
      // Set Goal Sheet
      'add_new_goal': 'Add New Goal',
      'edit_goal': 'Edit Goal',
      'create_new_savings_goal': 'Create new savings goal',
      'update_goal_name': 'Update goal "{name}"',
      'goal_name': 'Goal Name',
      'goal_name_hint': 'e.g. Buy House',
      'target_amount': 'Target Amount',
      'target_amount_hint': 'Target Amount (Rp)',
      'goal_info': 'This goal will not reset monthly',
      'save_goal': 'Save Goal',
      'update_goal': 'Update Goal',
      'name_and_amount_required': 'Goal name & target amount required',
      
      // Profile
      'settings': 'Settings',
      'account_settings': 'Account Settings',
      'app_theme': 'App Theme',
      'language': 'Language',
      'about_app': 'About App',
      'logout': 'Logout',
      'logout_confirmation': 'Logout?',
      'logout_message': 'You will be signed out of this account.',
      
      // Language
      'select_language': 'Select Language',
      'english': 'English',
      'indonesian': 'Indonesian',
      
      // Greetings
      'good_morning': 'Good Morning',
      'good_afternoon': 'Good Afternoon',
      'good_evening': 'Good Evening',
      'good_night': 'Good Night',
      'check_finances': "Let's check your finances!",
      
      // Errors
      'failed_to_load': 'Failed to load data',
      'try_again': 'Try Again',
      
      // Financial Advice
      'ai_advice': 'AI Advice',
      'very_good': 'Very Good',
      'healthy': 'Healthy',
      'needs_adjustment': 'Needs Adjustment',
      'critical': 'Critical',
      'not_analyzed': 'Not Analyzed',
    },
    'id': {
      // Common
      'app_name': 'ManKu',
      'cancel': 'Batal',
      'save': 'Simpan',
      'delete': 'Hapus',
      'edit': 'Edit',
      'confirm': 'Konfirmasi',
      'yes': 'Ya',
      'no': 'Tidak',
      'ok': 'OK',
      'loading': 'Memuat...',
      'error': 'Error',
      'success': 'Berhasil',
      'retry': 'Coba Lagi',
      
      // Navigation
      'nav_home': 'Beranda',
      'nav_history': 'Riwayat',
      'nav_add': 'Tambah',
      'nav_reports': 'Laporan',
      'nav_profile': 'Profil',
      
      // Home - Balance Card
      'total_balance': 'Total Saldo',
      'add_transaction': 'Tambah Transaksi',
      
      // Home - Monthly Balance
      'monthly_balance': 'Saldo Bulan Ini',
      'balance': 'saldo',
      'income': 'Pemasukan',
      'expense': 'Pengeluaran',
      'surplus': 'Surplus',
      'deficit': 'Defisit',
      
      // Home - Financial Goals
      'financial_goals': 'Tujuan Keuangan',
      'total_goals': 'Total Tujuan',
      'achieved': 'Tercapai',
      'progress': 'Progress',
      'tap_to_view': 'Tap untuk lihat detail',
      
      // Home - Stats
      'daily_expense': 'Pengeluaran Harian',
      
      // Home - Spending Performance
      'spending_performance': 'Performa Pengeluaran',
      'last_7_days': '7 Hari Terakhir',
      
      // Goals Page
      'budget_goals': 'Tujuan Anggaran',
      'long_term_savings': 'Tabungan Jangka Panjang',
      'total_target': 'TOTAL TARGET',
      'collected': 'Terkumpul',
      'remaining': 'Kurang',
      'add_goal': 'Tambah Tujuan',
      'savings_goals': 'Tujuan Tabungan',
      'goals_count': 'tujuan',
      'no_goals_yet': 'Belum Ada Tujuan',
      'add_savings_goal': 'Tambahkan tujuan tabungan untuk\nmencapai impianmu!',
      'delete_goal': 'Hapus Tujuan?',
      'goal_will_be_deleted': 'Tujuan "{name}" akan dihapus.',
      
      // Goal Status
      'safe': 'Aman',
      'approaching_target': 'Mendekati Target',
      'almost_achieved': 'Hampir Tercapai',
      'target_achieved': 'Target Tercapai!',
      'target_reached': 'Target tercapai! 🎉',
      'need_more': 'Kurang {amount}',
      
      // Set Goal Sheet
      'add_new_goal': 'Tambah Tujuan Baru',
      'edit_goal': 'Edit Tujuan',
      'create_new_savings_goal': 'Buat tujuan tabungan baru',
      'update_goal_name': 'Update tujuan "{name}"',
      'goal_name': 'Nama Tujuan',
      'goal_name_hint': 'contoh: Beli Rumah',
      'target_amount': 'Target Nominal',
      'target_amount_hint': 'Target Nominal (Rp)',
      'goal_info': 'Tujuan ini tidak akan reset setiap bulan',
      'save_goal': 'Simpan Tujuan',
      'update_goal': 'Update Tujuan',
      'name_and_amount_required': 'Nama tujuan & target wajib diisi',
      
      // Profile
      'settings': 'Pengaturan',
      'account_settings': 'Pengaturan Akun',
      'app_theme': 'Tema Aplikasi',
      'language': 'Bahasa',
      'about_app': 'Tentang Aplikasi',
      'logout': 'Keluar',
      'logout_confirmation': 'Keluar?',
      'logout_message': 'Kamu akan keluar dari akun ini.',
      
      // Language
      'select_language': 'Pilih Bahasa',
      'english': 'English',
      'indonesian': 'Bahasa Indonesia',
      
      // Greetings
      'good_morning': 'Selamat Pagi',
      'good_afternoon': 'Selamat Siang',
      'good_evening': 'Selamat Sore',
      'good_night': 'Selamat Malam',
      'check_finances': 'Yuk cek keuangan kamu!',
      
      // Errors
      'failed_to_load': 'Gagal memuat data',
      'try_again': 'Coba Lagi',
      
      // Financial Advice
      'ai_advice': 'Saran AI',
      'very_good': 'Sangat Baik',
      'healthy': 'Sehat',
      'needs_adjustment': 'Butuh Penyesuaian',
      'critical': 'Kritis',
      'not_analyzed': 'Belum Menganalisis',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Shorthand
  String get appName => translate('app_name');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  
  // Navigation
  String get navHome => translate('nav_home');
  String get navHistory => translate('nav_history');
  String get navAdd => translate('nav_add');
  String get navReports => translate('nav_reports');
  String get navProfile => translate('nav_profile');
  
  // Home
  String get totalBalance => translate('total_balance');
  String get monthlyBalance => translate('monthly_balance');
  String get income => translate('income');
  String get expense => translate('expense');
  String get surplus => translate('surplus');
  String get deficit => translate('deficit');
  String get financialGoals => translate('financial_goals');
  String get dailyExpense => translate('daily_expense');
  
  // And so on...
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
