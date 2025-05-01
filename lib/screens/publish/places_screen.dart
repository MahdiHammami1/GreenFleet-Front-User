import 'package:flutter/material.dart';

class PlacesScreen extends StatefulWidget {
  final Function(int seats, bool womenOnly) onNext;
  final VoidCallback onBack;

  const PlacesScreen({
    required this.onNext,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  int seats = 1;
  bool womenOnly = false;

  final Color primaryColor = const Color(0xFF1B4242);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How many passengers can you take?"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(Icons.remove, () {
                  setState(() {
                    if (seats > 1) seats--;
                  });
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    seats.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildIconButton(Icons.add, () {
                  setState(() {
                    if (seats < 4) seats++;
                  });
                }),
              ],
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Passenger Options',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckboxTile(
              icon: Icons.female,
              label: "Women Only",
              value: womenOnly,
              onChanged: (val) => setState(() => womenOnly = val!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onNext(seats, womenOnly);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      child: IconButton(
        icon: Icon(icon, color: primaryColor),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCheckboxTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.trailing,
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}