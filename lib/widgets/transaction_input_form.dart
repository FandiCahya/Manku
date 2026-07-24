import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/colors.dart';
import '../features/savings/data/savings_repository.dart';
import '../features/transactions/presentation/cubit/transaction_cubit.dart';
import '../features/transactions/presentation/cubit/transaction_state.dart';
import '../models/transaction_api.dart';

class TransactionInputForm extends StatefulWidget {
  final VoidCallback? onTransactionSaved;
  final ApiTransaction? existing;
  final String? existingDate;

  const TransactionInputForm({
    super.key,
    this.onTransactionSaved,
    this.existing,
    this.existingDate,
  });

  @override
  State<TransactionInputForm> createState() => _TransactionInputFormState();
}

class _TransactionInputFormState extends State<TransactionInputForm>
    with SingleTickerProviderStateMixin {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  String? selectedCategory;
  String selectedType = 'expense'; // 'expense' or 'income'
  DateTime selectedDate = DateTime.now();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  List<Map<String, String>> categories = [
    {'emoji': '🍔', 'label': 'Food'},
    {'emoji': '🚗', 'label': 'Transport'},
    {'emoji': '🛍️', 'label': 'Shopping'},
    {'emoji': '💡', 'label': 'Bills'},
    {'emoji': '🎮', 'label': 'Entertainment'},
    {'emoji': '💊', 'label': 'Health'},
    {'emoji': '📚', 'label': 'Education'},
    {'emoji': '💰', 'label': 'Income'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      amountController.text = widget.existing!.amount.toStringAsFixed(0);
      descriptionController.text = widget.existing!.description;
      selectedCategory = widget.existing!.categoryName;
      selectedType = widget.existing!.categoryType;
      if (widget.existingDate != null) {
        try {
          final parts = widget.existingDate!.split('-');
          selectedDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        } catch (_) {}
      }
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
    _loadUserBudgets();
  }

  Future<void> _loadUserBudgets() async {
    try {
      final data = await SavingsRepository.fetchBudgetGoals();
      if (data.budgets.isNotEmpty && mounted) {
        final List<Map<String, String>> loaded = [];
        
        // Income is always needed for income type transactions
        loaded.add({'emoji': '💰', 'label': 'Income'});

        for (final b in data.budgets) {
          final exists = loaded.any((c) => c['label']!.toLowerCase() == b.categoryName.toLowerCase());
          if (!exists) {
            loaded.add({
              'emoji': _emojiForCategory(b.categoryName),
              'label': b.categoryName,
            });
          }
        }

        final defaultCats = [
          {'emoji': '🍔', 'label': 'Food'},
          {'emoji': '🚗', 'label': 'Transport'},
          {'emoji': '🛍️', 'label': 'Shopping'},
          {'emoji': '💡', 'label': 'Bills'},
          {'emoji': '🎮', 'label': 'Entertainment'},
          {'emoji': '💊', 'label': 'Health'},
          {'emoji': '📚', 'label': 'Education'},
        ];

        for (final def in defaultCats) {
          final exists = loaded.any((c) => c['label']!.toLowerCase() == def['label']!.toLowerCase());
          if (!exists) {
            loaded.add(def);
          }
        }

        setState(() {
          categories = loaded;
        });
      }
    } catch (e) {
      debugPrint('Error loading custom budgets for categories: $e');
    }
  }

  String _emojiForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('makan') || lower.contains('food') || lower.contains('restoran')) return '🍔';
    if (lower.contains('transport') || lower.contains('bensin') || lower.contains('mobil') || lower.contains('motor')) return '🚗';
    if (lower.contains('belanja') || lower.contains('shopping') || lower.contains('beli')) return '🛍️';
    if (lower.contains('tagihan') || lower.contains('bill') || lower.contains('listrik') || lower.contains('air') || lower.contains('internet')) return '💡';
    if (lower.contains('hiburan') || lower.contains('entertainment') || lower.contains('game') || lower.contains('nonton')) return '🎮';
    if (lower.contains('sehat') || lower.contains('obat') || lower.contains('dokter') || lower.contains('health')) return '💊';
    if (lower.contains('didik') || lower.contains('sekolah') || lower.contains('kuliah') || lower.contains('buku') || lower.contains('education')) return '📚';
    if (lower.contains('tabung') || lower.contains('save') || lower.contains('menabung') || lower.contains('invest')) return '🐷';
    if (lower.contains('darurat') || lower.contains('emergency')) return '🚨';
    if (lower.contains('liburan') || lower.contains('holiday') || lower.contains('trip') || lower.contains('wisata')) return '🏖️';
    if (lower.contains('butuh') || lower.contains('wajib') || lower.contains('need')) return '📦';
    return '📝';
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final datePickerScheme = isDark
            ? ColorScheme.dark(
                primary: context.colors.primary,
                onPrimary: context.colors.onPrimary,
                surface: context.colors.surfaceContainerLowest,
                onSurface: context.colors.onSurface,
              )
            : ColorScheme.light(
                primary: context.colors.primary,
                onPrimary: context.colors.onPrimary,
                surface: context.colors.surfaceContainerLowest,
                onSurface: context.colors.onSurface,
              );
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: datePickerScheme),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _handleSubmit() {
    if (amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah terlebih dahulu')),
      );
      return;
    }

    final rawAmount = amountController.text.trim().replaceAll('.', '').replaceAll(',', '');
    final category = selectedCategory ?? 'Other';
    final desc = descriptionController.text.trim();
    final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    
    String timeStr;
    if (widget.existing != null && widget.existing!.time.isNotEmpty) {
      timeStr = widget.existing!.time;
    } else {
      timeStr = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    }
    
    final type = selectedType;

    if (widget.existing != null) {
      context.read<TransactionCubit>().updateTransaction(
        id: widget.existing!.id,
        amount: rawAmount,
        categoryHint: category,
        description: desc,
        date: dateStr,
        time: timeStr,
        type: type,
      );
    } else {
      context.read<TransactionCubit>().addManualTransaction(
        amount: rawAmount,
        categoryHint: category,
        description: desc,
        date: dateStr,
        time: timeStr,
        type: type,
      );
    }
  }

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
          // Reset form
          amountController.clear();
          descriptionController.clear();
          setState(() {
            selectedCategory = null;
            selectedType = 'expense';
            selectedDate = DateTime.now();
          });
          // Notify parent
          widget.onTransactionSaved?.call();
        } else if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TransactionSubmitting;

        return FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Toggle (Income / Expense)
                _buildTypeToggle(),
                const SizedBox(height: 20),

                // Amount Field
                _buildAmountField(),
                const SizedBox(height: 20),

                // Date Picker
                _buildDatePicker(),
                const SizedBox(height: 20),

                // Category Grid
                _buildCategorySection(),
                const SizedBox(height: 20),

                // Description Field
                _buildDescriptionField(),
                const SizedBox(height: 28),

                // Submit Button
                _buildSubmitButton(isLoading),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF0F1A24) 
            : context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _typeTab('expense', '💸 Pengeluaran'),
          _typeTab('income', '💵 Pemasukan'),
        ],
      ),
    );
  }

  Widget _typeTab(String type, String label) {
    final isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        // HitTestBehavior.opaque ensures the full tab area is tappable,
        // even when the background is Colors.transparent.
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (type == 'expense' ? context.colors.error : const Color(0xFF2e7d32))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (type == 'expense'
                              ? context.colors.error
                              : const Color(0xFF2e7d32))
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JUMLAH',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : context.colors.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF0F1A24) 
                : context.colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2A4A62)
                  : context.colors.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 4),
                child: Text(
                  'Rp',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primary.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 18,
                    ),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: context.colors.surfaceVariant,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TANGGAL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : context.colors.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF0F1A24) 
                  : context.colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A4A62)
                    : context.colors.outlineVariant.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18, 
                    color: isDark ? Colors.white70 : context.colors.primary),
                const SizedBox(width: 12),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : context.colors.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down,
                    color: isDark 
                        ? Colors.white54 
                        : context.colors.onSurfaceVariant.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KATEGORI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : context.colors.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: categories
              .map((c) => _buildCategoryButton(c['emoji']!, c['label']!))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String emoji, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C5F87) : context.colors.primaryContainer)
              : (isDark ? const Color(0xFF0F1A24) : context.colors.surfaceContainerLowest),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF4A7FAF) : context.colors.primary.withOpacity(0.5))
                : (isDark ? const Color(0xFF2A4A62) : context.colors.outlineVariant.withOpacity(0.3)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF2C5F87) : context.colors.primary).withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? Colors.white : context.colors.onPrimaryContainer)
                    : (isDark ? Colors.white70 : context.colors.onSurfaceVariant),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KETERANGAN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : context.colors.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 2,
          style: TextStyle(
            color: isDark ? Colors.white : context.colors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: Beli kopi di Starbucks...',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark 
                    ? const Color(0xFF2A4A62) 
                    : context.colors.outlineVariant.withOpacity(0.4)
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark 
                    ? const Color(0xFF2A4A62) 
                    : context.colors.outlineVariant.withOpacity(0.4)
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF4A7FAF) : context.colors.primary, 
                width: 1.5
              ),
            ),
            filled: true,
            fillColor: isDark 
                ? const Color(0xFF0F1A24) 
                : context.colors.surfaceContainerLowest,
            hintStyle: TextStyle(
              color: isDark 
                  ? Colors.white38 
                  : context.colors.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          disabledBackgroundColor: context.colors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: context.colors.primary.withOpacity(0.4),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(context.colors.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_alt, color: context.colors.onPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.colors.onPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
