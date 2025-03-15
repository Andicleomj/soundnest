import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap; // Menambahkan onTap agar bisa diklik

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap, // Parameter onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Gunakan fungsi onTap saat item diklik
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, width: 50, height: 50),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
