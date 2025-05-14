import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Atur posisi ke atas
        children: [
          Image.asset(
            icon,
            width: 50,
            height: 50,
          ),
          const SizedBox(height: 8), // Jarak label dengan icon
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
