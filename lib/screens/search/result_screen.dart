import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Ride_Response_dart.dart';
import '../../models/user_model.dart';
import '/models/booked_ride_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'booked_screen.dart';


class ResultScreen extends StatefulWidget {
  final List<RideResponse> rideResults;

  const ResultScreen({Key? key, required this.rideResults}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Results (${widget.rideResults.length})',
          style: TextStyle(
            color: Color(0xFF1b4242),
            fontSize: screenWidth * 0.045,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1b4242)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.rideResults.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No rides found',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search criteria',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1b4242),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Modify Search',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.rideResults.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final ride = widget.rideResults[index];
                      return _buildRideCard(context, ride);
                    },
                  ),
                ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1b4242),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Back to Search',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRideCard(BuildContext context, RideResponse ride) {
    final userModel = Provider.of<UserModel>(context);
    final user = userModel.user;
    final token = userModel.token;
    final passengerId = user?['userId'];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1b4242),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    ride.driverName.substring(0, 1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1b4242),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.driverName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        ride.carName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: _buildStarRating(ride.rateDriver),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${ride.rateDriver.toStringAsFixed(1)}/5.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.location_pin,
                  iconColor: Colors.redAccent,
                  title: 'Pickup Point',
                  value: ride.stopoverName,
                ),
                SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.linear_scale,
                  iconColor: Colors.blueAccent,
                  title: 'Distance',
                  value: ride.distanceBetween,
                ),
                if (ride.prefrences.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.tune,
                    iconColor: Colors.orangeAccent,
                    title: 'Preferences',
                    value: ride.prefrences.join(', '),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.message_outlined, size: 20),
                        label: Text('Message'),
                        onPressed: () => _showMessageDialog(context, ride),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF1b4242),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Color(0xFF1b4242)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.directions_car, size: 20),
                        label: Text('Book Now'),
                        onPressed: () {
                          handleBook(
                              context,
                              passengerId,
                              // Replace with the correct passengerId
                              ride.rideId,
                              ride.stopoverName,
                              token!
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookedScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1b4242),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),


                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarRating(double rating) {
    return List.generate(5, (index) {
      if (index < rating.floor()) {
        return Icon(Icons.star, size: 16, color: Colors.amber);
      } else if (index == rating.floor() && rating % 1 >= 0.5) {
        return Icon(Icons.star_half, size: 16, color: Colors.amber);
      } else {
        return Icon(Icons.star_border, size: 16, color: Colors.amber);
      }
    });
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMessageDialog(BuildContext context, RideResponse ride) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Message ${ride.driverName}'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Message sent to ${ride.driverName}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1b4242),
                ),
                child: Text('Send'),
              ),
            ],
          ),
    );
  }

  void _showBookingDialog(BuildContext context, RideResponse ride) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Confirm Booking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF1b4242)),
                  title: Text('Driver'),
                  subtitle: Text(ride.driverName),
                ),
                ListTile(
                  leading: Icon(Icons.directions_car, color: Color(0xFF1b4242)),
                  title: Text('Vehicle'),
                  subtitle: Text(ride.carName),
                ),
                ListTile(
                  leading: Icon(Icons.star, color: Color(0xFF1b4242)),
                  title: Text('Rating'),
                  subtitle: Text(ride.rateDriver.toStringAsFixed(1)),
                ),
                SizedBox(height: 16),
                Text(
                  'Confirm ride request with ${ride.driverName}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBookingConfirmation(context, ride);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1b4242),
                ),
                child: Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _showBookingConfirmation(BuildContext context, RideResponse ride) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Booking Confirmed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your ride with ${ride.driverName} has been confirmed!'),
                SizedBox(height: 16),
                Text(
                  'Driver will contact you shortly',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Close both dialogs
                },
                child: Text('Done'),
              ),
            ],
          ),
    );
  }

  Future<void> handleBook(BuildContext context, int? passengerId, int rideId,
      String pickupLocation, String? token) async {
    if (passengerId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Missing passenger information or token.')),
      );
      return;
    }

    // Create the Booked object
    Booked booked = Booked.initial(
      passengerId: passengerId,
      rideId: rideId,
      pickupLocation: pickupLocation,
    );

    // Convert the Booked object to JSON
    String jsonPayload = jsonEncode(booked.toJson());

    print('JSON Payload Sent: $jsonPayload');

    try {
      // Send the booking request
      final response = await http.post(
        Uri.parse('http://localhost:8080/bookings/create/$rideId/$passengerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking successful!')),
        );

        // Show BookedScreen as a card-like dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: EdgeInsets.all(20), // Margin from all sides
              child: BookedScreen(), // Make sure this is a widget that fits well in a dialog
            );
          },
        );
      }
      else {
        // Handle server error
        print('Server error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book. Please try again.')),
        );
      }
    } catch (e) {
      // Handle network error
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please try again.')),
      );
    }
  }
}