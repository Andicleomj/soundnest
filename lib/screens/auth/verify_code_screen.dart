import 'package:flutter/material.dart';
import 'package:soundnest/utils/app_routes.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(5, (index) => TextEditingController());

  void _verifyCode() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 5-digit code")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Code Verified: $code")),
    );

    // Navigasi ke halaman Reset Password
    Navigator.pushNamed(context, AppRoutes.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Check your email",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "We sent a reset link to your email",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Verify Code",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
