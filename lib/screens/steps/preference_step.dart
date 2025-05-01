import 'package:flutter/material.dart';

class PreferenceStep extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String preference) onSubmit;

  const PreferenceStep({
    Key? key,
    required this.onBack,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _PreferenceStepState createState() => _PreferenceStepState();
}

class _PreferenceStepState extends State<PreferenceStep> {
  String? selectedPreference;
  final Color primaryColor = const Color(0xFF1B4242);

  final List<String> preferences = [
    "Mr.",
    "Ms./Mrs.",

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How would you like to be addressed?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ...preferences.map(
                  (option) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedPreference == option
                        ? primaryColor
                        : primaryColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: selectedPreference,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() => selectedPreference = value);
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onBack,
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedPreference != null) {
                      widget.onSubmit(selectedPreference!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a preference.")),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
