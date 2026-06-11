import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/chat_transaction_input.dart';
import '../../../../widgets/transaction_input_form.dart';

class AddTransactionTab extends StatefulWidget {
  const AddTransactionTab({
    required this.onTransactionSaved,
    super.key,
  });

  final VoidCallback onTransactionSaved;

  @override
  State<AddTransactionTab> createState() => _AddTransactionTabState();
}

class _AddTransactionTabState extends State<AddTransactionTab> {
  bool _isFormMode = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: Column(
        children: [
          _AddTransactionHeader(
            isFormMode: _isFormMode,
            onToggle: () => setState(() => _isFormMode = !_isFormMode),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A4A62) : null,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _isFormMode
                  ? TransactionInputForm(
                      key: const ValueKey('form'),
                      onTransactionSaved: widget.onTransactionSaved,
                    )
                  : ChatTransactionInput(
                      key: const ValueKey('chat'),
                      onTransactionSaved: widget.onTransactionSaved,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTransactionHeader extends StatelessWidget {
  const _AddTransactionHeader({
    required this.isFormMode,
    required this.onToggle,
  });

  final bool isFormMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFormMode ? 'Form Manual' : 'Chat AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : context.colors.secondary,
                ),
              ),
              Text(
                isFormMode
                    ? 'Isi data transaksi secara manual'
                    : 'Ceritakan transaksimu dengan teks',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark 
                      ? Colors.white70 
                      : context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isFormMode
                    ? (isDark ? const Color(0xFF2C5F87) : context.colors.primaryContainer)
                    : (isDark ? const Color(0xFF3D5A6B) : context.colors.secondaryContainer),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isFormMode 
                        ? (isDark ? const Color(0xFF2C5F87) : context.colors.primary)
                        : (isDark ? const Color(0xFF3D5A6B) : context.colors.secondary))
                        .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFormMode ? Icons.chat_bubble_outline : Icons.edit_note,
                    size: 16,
                    color: isDark
                        ? Colors.white
                        : (isFormMode
                            ? context.colors.onPrimaryContainer
                            : context.colors.onSecondaryContainer),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFormMode ? 'Chat AI' : 'Form Manual',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : (isFormMode
                              ? context.colors.onPrimaryContainer
                              : context.colors.onSecondaryContainer),
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
}
