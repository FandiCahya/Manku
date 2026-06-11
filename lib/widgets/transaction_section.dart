import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'transaction_item.dart';

class TransactionSection extends StatelessWidget {
  final String dateTitle;
  final List<TransactionModel> transactions;

  const TransactionSection({
    required this.dateTitle, required this.transactions, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C5B72),
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        ...transactions.map((tx) => TransactionItem(transaction: tx)),
      ],
    );
  }
}
