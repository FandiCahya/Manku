import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/colors.dart';
import '../features/transactions/presentation/cubit/transaction_cubit.dart';


class ChatTransactionInput extends StatefulWidget {
  final VoidCallback? onTransactionSaved;

  const ChatTransactionInput({super.key, this.onTransactionSaved});

  @override
  State<ChatTransactionInput> createState() => _ChatTransactionInputState();
}

class _ChatTransactionInputState extends State<ChatTransactionInput> {
  final textController = TextEditingController();
  final List<ChatMessage> messages = [];
  bool isLoading = false;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final input = textController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(text: input, isUser: true, timestamp: DateTime.now()),
      );
      isLoading = true;
    });

    textController.clear();

    try {
      final data = await context.read<TransactionCubit>().addChatTransaction(input);
      if (!mounted) return;

      if (data != null) {
        final extracted = data.extractedData;
        setState(() {
          isLoading = false;
          if (extracted != null && extracted.amount != null) {
            final now = DateTime.now();
            final timeStr =
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
            
            String dateStr = '${now.day}/${now.month}/${now.year}';
            if (extracted.date != null) {
               final parts = extracted.date!.split('-');
               if (parts.length == 3) {
                  dateStr = '${parts[2]}/${parts[1]}/${parts[0]}';
               }
            }

            final parsed = {
               'amount': extracted.amount!.toStringAsFixed(0),
               'category': extracted.categoryHint ?? 'Other',
               'description': extracted.description ?? '',
               'type': extracted.type ?? 'expense',
            };

            messages.add(
              ChatMessage(
                text:
                    '✅ Tersimpan!\n💰 Rp${parsed['amount']} | ${parsed['category']}\n📝 ${parsed['description']}\n⏰ $timeStr • $dateStr',
                isUser: false,
                timestamp: now,
                isParsed: true,
              ),
            );
            // Notify parent to refresh data
            widget.onTransactionSaved?.call();
          } else {
             messages.add(
              ChatMessage(
                text:
                    'Maaf, saya tidak menemukan nominal. Coba seperti ini:\n"Saya beli kopi 25000"',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          }
        });
      } else {
         setState(() {
          isLoading = false;
          messages.add(
            ChatMessage(
              text: 'Maaf, terjadi kesalahan pada server atau data tidak valid.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        messages.add(
          ChatMessage(
            text: 'Maaf, gagal terhubung ke server.\nPastikan server sudah berjalan.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '💬 Ceritakan transaksimu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: context.colors.outlineVariant.withOpacity(0.3)),
          // Chat messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👋', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          'Mulai dengan menceritakan transaksimu',
                          style: TextStyle(
                            color: context.colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contoh: "Saya beli kopi 25000"',
                          style: TextStyle(
                            color: context.colors.onSurfaceVariant.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isLoading && index == messages.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryContainer.withOpacity(
                                    0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Color(0xFF2c5f87),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final message = messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          // Input field
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload Image clicked')),
                    );
                  },
                  icon: Icon(Icons.image_outlined, color: context.colors.secondary),
                  tooltip: 'Upload Receipt',
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice Input clicked')),
                    );
                  },
                  icon: Icon(Icons.mic_none, color: context.colors.secondary),
                  tooltip: 'Use Voice',
                ),
                Expanded(
                  child: TextField(
                    controller: textController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Cth: "Beli kopi 25000"',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: context.colors.surfaceContainer,
                      hintStyle: TextStyle(
                        color: context.colors.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: context.colors.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: context.colors.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (message.isParsed) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2e7d32).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF2e7d32).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Color(0xFF2e7d32)),
                    SizedBox(width: 5),
                    Text(
                      'Tersimpan otomatis',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2e7d32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isParsed;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isParsed = false,
  });
}
