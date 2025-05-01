
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride_screen.dart';
import '../../models/user_model.dart';
import '../home_screen.dart';
import 'package:http/http.dart' as http;

class ConfirmationScreen extends StatefulWidget {
  RideData rideData;

  ConfirmationScreen({Key? key, required this.rideData}) : super(key: key);

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _showPhone = false;
  final String _driverPhone = "23423423";





  Future<void> _saveRide(bool shouldPublish) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final token = userModel.token;

    // Update the published state
    setState(() {
      widget.rideData.published = shouldPublish;
    });

    // Prepare JSON data for the request
    final rideJson = widget.rideData.toJson();
    print(userModel.user?['userId']);
    // Use JsonEncoder to pretty-print the JSON string
    final jsonString = JsonEncoder.withIndent('  ').convert(rideJson);


    // Print the updated state (pretty-printed JSON)
    print(jsonString);

    try {
      // Make the HTTP POST request to your server
      final response = await http.post(
          Uri.parse('http://localhost:8080/rides'), //
          headers: {
            'Content-Type': 'application/json',
            // Add any authentication headers if needed
            'Authorization': 'Bearer $token',
          },
          body: jsonString,

      );


      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("7chinehhhhhhhhhhhhhhh");

        // Show a success Snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              shouldPublish ? "Ride saved and published!" : "Ride saved as draft",
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: const Color(0xFF1B4242),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to HomeScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );
      } else {
        // Show error message if the request failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error saving ride: ${response.statusCode}",
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle network or other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to connect to server: $e",
            style: const TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final user = userModel.user;
    final driverPhone = user?['phoneNumber'];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text(
          "Your Ride Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF1B4242),
        centerTitle: true,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSectionHeader("Ride Information"),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.person,
                title: "Driver Name",
                value:user?['firstname'],
                onEdit: () {
                  // TODO: Navigate to edit driver name
                },
              ),
              _buildPhoneCard(),
              _buildInfoCard(
                icon: Icons.calendar_today,
                title: "Date",
                value: widget.rideData.rideDate != null
                    ? "${widget.rideData.rideDate!.toLocal()}".split(' ')[0]
                    : "N/A",
                onEdit: () {
                  // TODO: Navigate to edit date
                },
              ),
              _buildInfoCard(
                icon: Icons.access_time,
                title: "Time",
                value: widget.rideData.rideTime != null
                    ? "${widget.rideData.rideTime!.hour.toString().padLeft(2, '0')}:${widget.rideData.rideTime!.minute.toString().padLeft(2, '0')}"
                    : "N/A",
                onEdit: () {
                  // TODO: Navigate to edit time
                },
              ),
              _buildInfoCard(
                icon: Icons.airline_seat_recline_normal,
                title: "Seats Available",
                value: widget.rideData.numberOfSeat?.toString() ?? "N/A",
                onEdit: () {
                  // TODO: Navigate to edit seats
                },
              ),
              const SizedBox(height: 24),

              _buildSectionWithHeader(
                title: "Stopovers",
                onEdit: () {
                  // TODO: Navigate to edit stopovers
                },
                child: _buildStopoversList(),
              ),

              const SizedBox(height: 24),

              _buildSectionWithHeader(
                title: "Preferences",
                onEdit: () {
                  // TODO: Navigate to edit preferences
                },
                child: _buildPreferencesList(),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1B4242)),
                      label: const Text("Back", style: TextStyle(color: Color(0xFF1B4242))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1B4242)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveRide(false),
                      icon: const Icon(Icons.save_outlined, color: Colors.white),
                      label: const Text(
                        "Save Draft",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () => _saveRide(true),
                icon: const Icon(Icons.publish, color: Colors.white),
                label: const Text(
                  "Save & Publish",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4242),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B4242),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1B4242)),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1B4242), size: 20),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.phone, color: Color(0xFF1B4242)),
          ),
          title: const Text(
            "Driver Phone",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _showPhone ? _driverPhone : "••• ••• ••••",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              _showPhone ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF1B4242),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showPhone = !_showPhone;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionWithHeader({
    required String title,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(title),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 16, color: Color(0xFF1B4242)),
              label: const Text(
                "Edit",
                style: TextStyle(color: Color(0xFF1B4242), fontWeight: FontWeight.w500),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildStopoversList() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.rideData.stopovers.isNotEmpty
            ? Column(
          children: List.generate(widget.rideData.stopovers.length * 2 - 1, (index) {
            if (index % 2 == 0) {
              final stopoverIndex = index ~/ 2;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, color: Color(0xFF1B4242), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.rideData.stopovers[stopoverIndex].location?.nameLocation ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Container(
                  height: 20,
                  width: 2,
                  color: const Color(0xFFB0D1D1),
                ),
              );
            }
          }),
        )
            : const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "No stopovers added",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesList() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.rideData.preferences.isNotEmpty
            ? Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.rideData.preferences.map((pref) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F0F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFB0D1D1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF1B4242),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pref,
                    style: const TextStyle(
                      color: Color(0xFF1B4242),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
            : const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "No preferences selected",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}