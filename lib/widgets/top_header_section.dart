import 'package:flutter/material.dart';

class TopHeaderSection extends StatelessWidget {
  const TopHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hello, Saver!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Color(0xFF0D1B2A)),
          onPressed: () {},
        ),
      ],
    );
  }
}
