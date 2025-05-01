import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import 'location_picker_screen.dart';
import '/models/location_data.dart';

class PublishScreen extends StatefulWidget {
  final Function({
  required Location address,
  required DateTime date,
  required TimeOfDay time,
  required int driverId,
  required int carId, // ✅ Ajouté ici
  }) onNext;

  const PublishScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  Location? address;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedCarName;
  int? selectedCarId;

  final Color primaryColor = const Color(0xFF1B4242);
  final Color secondaryColor = const Color(0xFF5C8374);

  Future<void> _handleMapSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(title: 'Select Address'),
      ),
    );

    if (result != null && result is Location) {
      setState(() {
        address = result;
      });
    }
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });
      }
    }
  }

  Widget _buildField(String label, String value, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(_getIcon(label), color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: value.contains("Tap") ? Colors.grey : Colors.black,
                  fontWeight: value.contains("Tap") ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String label) {
    switch (label) {
      case 'Address':
        return Icons.home_rounded;
      case 'Date & Time':
        return Icons.calendar_month_rounded;
      default:
        return Icons.directions_car_filled_rounded;
    }
  }

  Widget _buildCarDropdown(List<Map<String, dynamic>> carOptions) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedCarName,
          hint: const Text('Select a Car'),
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            final car = carOptions.firstWhere((car) => car['name'] == newValue);
            setState(() {
              selectedCarName = car['name'];
              selectedCarId = car['id'];
            });
          },
          items: carOptions.map((car) {
            return DropdownMenuItem<String>(
              value: car['name'],
              child: Text(car['name']!),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final vehicles = userModel.vehicles;
    final List<Map<String, dynamic>> carOptions = vehicles
        .map((v) => {'name': v.brand, 'id': v.vehicleId})
        .toList();


    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Text("Publish Ride"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildField('Address', address?.nameLocation ?? 'Tap to select Address', _handleMapSelection),
              _buildField(
                'Date & Time',
                (selectedDate != null && selectedTime != null)
                    ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} • ${selectedTime!.format(context)}"
                    : 'Tap to select Date & Time',
                _selectDateTime,
              ),
              _buildCarDropdown(carOptions), // ✅ Ajout du menu déroulant de voiture
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (address != null &&
                        selectedDate != null &&
                        selectedTime != null &&
                        selectedCarId != null) {
                      widget.onNext(
                        address: address!,
                        date: selectedDate!,
                        time: selectedTime!,
                        driverId:  userModel.user?['userId'],
                        carId: selectedCarId!, // ✅ Transmet le carId choisi
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  label: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}