import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/budget_models.dart';
import '../cubit/savings_cubit.dart';

/// Bottom sheet for setting or editing a budget category.
class SetBudgetSheet extends StatefulWidget {
  const SetBudgetSheet({this.existing, this.monthLabel, super.key});

  final BudgetGoalItem? existing;
  final String? monthLabel;

  @override
  State<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends State<SetBudgetSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.existing?.categoryName ?? '');
    _amountCtrl = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.budgetAmount.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(
      _amountCtrl.text.replaceAll('.', '').replaceAll(',', ''),
    );

    if ((name.isEmpty && !_isEditing) || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama kategori & jumlah wajib diisi'),
        ),
      );
      return;
    }

    Navigator.pop(context);
    context.read<SavingsCubit>().setCategoryBudget(
          categoryName: _isEditing ? widget.existing!.categoryName : name,
          amount: amount,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 20),
          _SheetTitle(isEditing: _isEditing, existing: widget.existing),
          const SizedBox(height: 24),
          _CategoryField(
            controller: _nameCtrl,
            isEditing: _isEditing,
          ),
          const SizedBox(height: 14),
          _AmountField(controller: _amountCtrl),
          const SizedBox(height: 24),
          _MonthInfoChip(monthLabel: widget.monthLabel),
          const SizedBox(height: 24),
          _SubmitButton(
            isEditing: _isEditing,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.isEditing, required this.existing});

  final bool isEditing;
  final BudgetGoalItem? existing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditing ? 'Edit Budget' : 'Set Budget Baru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isEditing
              ? 'Update budget untuk kategori "${existing!.categoryName}"'
              : 'Tentukan batas pengeluaran per kategori',
          style: TextStyle(fontSize: 13, color: context.colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.controller,
    required this.isEditing,
  });

  final TextEditingController controller;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: !isEditing,
      decoration: InputDecoration(
        hintText: 'Nama Kategori (contoh: Makanan)',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(Icons.category_outlined,
            color: context.colors.primary, size: 20),
        filled: true,
        fillColor: isEditing
            ? context.colors.surfaceContainerHighest.withValues(alpha: 0.4)
            : context.colors.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: context.colors.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Jumlah Budget (Rp)',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(Icons.account_balance_wallet_outlined,
            color: context.colors.primary, size: 20),
        filled: true,
        fillColor: context.colors.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: context.colors.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _MonthInfoChip extends StatelessWidget {
  const _MonthInfoChip({this.monthLabel});

  final String? monthLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: context.colors.primary),
          const SizedBox(width: 8),
          Text(
            'Budget berlaku untuk bulan ${monthLabel ?? 'ini'}',
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isEditing,
    required this.onPressed,
  });

  final bool isEditing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          isEditing ? 'Update Budget' : 'Set Budget',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
