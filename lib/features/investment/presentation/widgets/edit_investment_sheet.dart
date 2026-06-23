import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/investment_models.dart';
import '../cubit/investment_cubit.dart';
import '../cubit/investment_state.dart';

class EditInvestmentSheet extends StatefulWidget {
  final Investment investment;
  const EditInvestmentSheet({required this.investment, super.key});

  @override
  State<EditInvestmentSheet> createState() => _EditInvestmentSheetState();
}

class _EditInvestmentSheetState extends State<EditInvestmentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _buyPriceCtrl;
  late final TextEditingController _notesCtrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantityCtrl = TextEditingController(
      text: widget.investment.quantity.toStringAsFixed(
        widget.investment.isCrypto ? 8 : 2,
      ),
    );
    _buyPriceCtrl = TextEditingController(
      text: widget.investment.buyPrice.toStringAsFixed(0),
    );
    _notesCtrl = TextEditingController(text: widget.investment.notes ?? '');
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _buyPriceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<InvestmentCubit>().editInvestment(
            id: widget.investment.id,
            quantity: double.tryParse(_quantityCtrl.text.trim()),
            buyPrice: double.tryParse(_buyPriceCtrl.text.trim()),
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Investment berhasil diperbarui!'),
            ]),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1D3448) : Colors.white;
    final inv = widget.investment;

    return BlocListener<InvestmentCubit, InvestmentState>(
      listener: (context, state) {
        if (state is InvestmentSubmitting) {
          setState(() => _isSubmitting = true);
        } else if (state is InvestmentSubmitSuccess || state is InvestmentLoaded) {
          setState(() => _isSubmitting = false);
        } else if (state is InvestmentError) {
          setState(() => _isSubmitting = false);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.orange,
                        Colors.orange.withOpacity(0.7),
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Investment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        Text(
                          '${inv.symbol} · ${inv.isCrypto ? 'Crypto' : 'Saham'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Read-only info chip
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.outline.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Symbol & jenis aset tidak dapat diubah',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24, 16, 24,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quantity & Buy Price
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label(inv.isCrypto ? 'Jumlah (Koin)' : 'Jumlah (Lot/Lembar)'),
                                const SizedBox(height: 8),
                                _textField(
                                  controller: _quantityCtrl,
                                  hint: '0.5',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                  ],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                                    if (double.tryParse(v) == null) return 'Angka tidak valid';
                                    if (double.parse(v) <= 0) return 'Harus > 0';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Harga Beli (Rp)'),
                                const SizedBox(height: 8),
                                _textField(
                                  controller: _buyPriceCtrl,
                                  hint: '500000',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                                    if (double.tryParse(v) == null) return 'Angka tidak valid';
                                    if (double.parse(v) <= 0) return 'Harus > 0';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Notes
                      _label('Catatan (opsional)'),
                      const SizedBox(height: 8),
                      _textField(
                        controller: _notesCtrl,
                        hint: 'Contoh: beli di Ajaib, target jangka panjang...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // Preview
                      if (_quantityCtrl.text.isNotEmpty && _buyPriceCtrl.text.isNotEmpty)
                        _buildPreview(),

                      const SizedBox(height: 8),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text('Simpan Perubahan',
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final price = double.tryParse(_buyPriceCtrl.text) ?? 0;
    final total = qty * price;
    final formatted = total
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.orange.withOpacity(0.15),
          Colors.orange.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          const Text('Total Modal', style: TextStyle(fontSize: 13)),
          const Spacer(),
          Text('Rp $formatted',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.onSurfaceVariant,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        fontSize: 14,
        color: context.colors.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.colors.onSurfaceVariant.withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: context.colors.surfaceContainer.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.error),
        ),
      ),
    );
  }
}
