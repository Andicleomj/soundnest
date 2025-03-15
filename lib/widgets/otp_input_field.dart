import 'package:flutter/material.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final int otpLength;

  const OtpInputField({super.key, required this.controller, this.otpLength = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        otpLength,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "", // Menghilangkan counter text
              ),
            ),
          ),
        ),
      ),
    );
  }
}
