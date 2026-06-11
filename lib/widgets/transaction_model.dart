import 'package:flutter/material.dart';

class TransactionModel {
  final String title;
  final String time;
  final double amount;
  final String type;
  final IconData iconData;
  final Color backgroundColor;
  final Color iconColor;

  TransactionModel({
    required this.title,
    required this.time,
    required this.amount,
    required this.type,
    required this.iconData,
    required this.backgroundColor,
    required this.iconColor,
  });
}
