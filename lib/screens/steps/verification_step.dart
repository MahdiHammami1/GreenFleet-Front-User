import 'package:flutter/material.dart';
import 'dart:async';

class VerificationStep extends StatefulWidget {
  final Function(String code) onSubmit;
  final VoidCallback onBack;

  const VerificationStep({Key? key, required this.onSubmit, required this.onBack}) : super(key: key);

  @override
  State<VerificationStep> createState() => _VerificationStepState();
}

class _VerificationStepState extends State<VerificationStep> {
  final TextEditingController _codeController = TextEditingController();
  final Color primaryColor = const Color(0xFF1B4242);

  int _secondsRemaining = 30;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        _timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Verification",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Enter the code sent to your phone/email.",
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "Please wait ${_secondsRemaining}s before resending the code.",
              style: TextStyle(color: primaryColor.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Verification Code",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onBack,
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_codeController.text.isNotEmpty) {
                      widget.onSubmit(_codeController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter the verification code.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _secondsRemaining == 0 ? _startCountdown : null,
              child: Text(
                _secondsRemaining == 0 ? "Resend Code" : "Wait...",
                style: TextStyle(
                  color: _secondsRemaining == 0
                      ? primaryColor
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
