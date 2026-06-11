import re

file_path = 'd:/Project Flutter/my_manage/lib/widgets/chat_transaction_input.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update imports
new_imports = '''import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/colors.dart';
import '../constants/api_config.dart';'''
content = re.sub(r'import \'package:flutter/material\.dart\';\nimport \'../constants/colors\.dart\';', new_imports, content)

# 2. Replace the methods
replacement = r'''  @override
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
      final response = await http.post(
        Uri.parse(ApiConfig.chatInputEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': input}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final extracted = data['extracted_data'];

        setState(() {
          isLoading = false;
          if (extracted != null && extracted['amount'] != null) {
            final now = DateTime.now();
            final timeStr =
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
            
            String dateStr = '${now.day}/${now.month}/${now.year}';
            if (extracted['date'] != null) {
               final parts = extracted['date'].toString().split('-');
               if (parts.length == 3) {
                  dateStr = '${parts[2]}/${parts[1]}/${parts[0]}';
               }
            }

            final parsed = {
               'amount': extracted['amount'].toString(),
               'category': extracted['category_hint'] ?? 'Other',
               'description': extracted['description'] ?? '',
               'type': extracted['type'] ?? 'expense',
            };

            messages.add(
              ChatMessage(
                text:
                    '💰 Rp${parsed['amount']} | ${parsed['category']} | ${parsed['description']}\n⏰ $timeStr • $dateStr',
                isUser: false,
                timestamp: now,
                isParsed: true,
                parsedData: parsed,
              ),
            );
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
              text: 'Maaf, terjadi kesalahan pada server (Error ${response.statusCode}).',
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
  }'''

# Find start of categoryKeywords and end of _parseTransaction
start_idx = content.find('  // Category keywords mapping')
end_idx = content.find('  void _confirmTransaction(ChatMessage message)')

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + replacement + '\n\n' + content[end_idx:]
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Successfully updated file')
else:
    print('Failed to find indices')
