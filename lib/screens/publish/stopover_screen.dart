import 'package:flutter/material.dart';
import 'location_picker_screen.dart';
import '/models/location_data.dart';

class StopoverScreen extends StatefulWidget {
  final Location startAddress;
  final Function(List<Location>) onNext;
  final VoidCallback onBack;

  const StopoverScreen({
    required this.startAddress,
    required this.onNext,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  State<StopoverScreen> createState() => _StopoverScreenState();
}

class _StopoverScreenState extends State<StopoverScreen> {
  final Color primaryColor = const Color(0xFF1B4242);
  List<Location> stopovers = [];

  void _addStopover() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationPickerScreen(title: "Pick Stopover"),
      ),
    );

    if (result != null && result is Location) {
      setState(() {
        stopovers.add(result);
      });
    }
  }

  Widget _buildLocationTile(String text, IconData icon, {bool isPrimary = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isPrimary ? primaryColor.withOpacity(0.1) : Colors.white,
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> routeWidgets = [
      _buildLocationTile(widget.startAddress.nameLocation, Icons.location_on, isPrimary: true),
      ...stopovers.map((stop) => _buildLocationTile(stop.nameLocation, Icons.stop_circle_outlined)),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Stopovers"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ...routeWidgets,
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addStopover,
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text("Add Stopover"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onNext(stopovers);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}