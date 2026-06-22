import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../cubit/investment_cubit.dart';
import '../cubit/investment_state.dart';

class AddInvestmentSheet extends StatefulWidget {
  const AddInvestmentSheet({super.key});

  @override
  State<AddInvestmentSheet> createState() => _AddInvestmentSheetState();
}

class _AddInvestmentSheetState extends State<AddInvestmentSheet> {
  final _formKey = GlobalKey<FormState>();

  String _assetType = 'crypto'; // 'crypto' or 'stock'
  final _symbolCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _buyPriceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await context.read<InvestmentCubit>().addInvestment(
        assetType: _assetType,
        symbol: _symbolCtrl.text.trim().toUpperCase(),
        name: _nameCtrl.text.trim(),
        quantity: double.parse(_quantityCtrl.text.trim()),
        buyPrice: double.parse(_buyPriceCtrl.text.trim()),
        purchaseDate: _purchaseDate,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Investment berhasil ditambahkan!'),
              ],
            ),
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
        height: MediaQuery.of(context).size.height * 0.88,
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
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primary,
                          context.colors.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: context.colors.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Investment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      Text(
                        'Catat aset crypto atau saham kamu',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    20,
                    24,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Asset Type Toggle
                      _label('Jenis Aset'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _assetTypeBtn(
                              label: '🪙 Crypto',
                              value: 'crypto',
                            ),
                            _assetTypeBtn(
                              label: '📊 Saham',
                              value: 'stock',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Symbol & Name in a row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Symbol'),
                                const SizedBox(height: 8),
                                _textField(
                                  controller: _symbolCtrl,
                                  hint: _assetType == 'crypto' ? 'BTC, ETH...' : 'BBCA, TLKM...',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  textCapitalization: TextCapitalization.characters,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Nama Aset'),
                                const SizedBox(height: 8),
                                _textField(
                                  controller: _nameCtrl,
                                  hint: _assetType == 'crypto' ? 'Bitcoin' : 'Bank Central Asia',
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quantity & Buy Price
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label(_assetType == 'crypto' ? 'Jumlah (Koin)' : 'Jumlah (Lot/Lembar)'),
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
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
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Purchase Date
                      _label('Tanggal Pembelian'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainer.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.colors.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: context.colors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${_purchaseDate.day.toString().padLeft(2, '0')}/'
                                '${_purchaseDate.month.toString().padLeft(2, '0')}/'
                                '${_purchaseDate.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.colors.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Notes (optional)
                      _label('Catatan (opsional)'),
                      const SizedBox(height: 8),
                      _textField(
                        controller: _notesCtrl,
                        hint: 'Contoh: beli di Indodax, target jangka panjang...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Preview total cost
                      if (_quantityCtrl.text.isNotEmpty && _buyPriceCtrl.text.isNotEmpty)
                        _buildCostPreview(),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            foregroundColor: context.colors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_chart, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Simpan Investment',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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

  Widget _assetTypeBtn({required String label, required String value}) {
    final selected = _assetType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _assetType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected
                  ? context.colors.onPrimary
                  : context.colors.onSurfaceVariant,
            ),
          ),
        ),
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}), // untuk update preview
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.colors.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.colors.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.colors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.error),
        ),
      ),
    );
  }

  Widget _buildCostPreview() {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final price = double.tryParse(_buyPriceCtrl.text) ?? 0;
    final total = qty * price;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primaryContainer.withOpacity(0.4),
            context.colors.primaryContainer.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calculate_rounded,
            color: context.colors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Total Investasi',
            style: TextStyle(
              fontSize: 13,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            'Rp ${_formatNumber(total)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
