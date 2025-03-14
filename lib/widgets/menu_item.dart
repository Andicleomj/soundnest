import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String icon;
  final String label;

  const MenuItem({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[100], // Background biru muda sesuai gambar
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            icon,
            width: 50,
            height: 50,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
