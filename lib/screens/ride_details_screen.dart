import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../dto/RideDTO.dart';
import '../models/user_model.dart';
import 'chat_screen.dart'; // Import the chat screen
import 'my_rides_screen.dart'; // Import the my rides screen

class RideDetailsScreen extends StatefulWidget {
  final int rideId;

  const RideDetailsScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  late Map<String ,dynamic> ride;
  RideDTO? ridetmp;
  int userPoints = 0; // Track user points
  String? carName;



  // API configuration

  // global list<vehicle> vehicles

  @override
  void initState() {
    super.initState();
    _fetchRideDetails(widget.rideId);
    // Define the ride data directly inside the screen
  }

  void _fetchRideDetails(int rideId) {

    print("LRIDEEEEEEEEE ID " + '$rideId' );
    final userModel = Provider.of<UserModel>(context, listen: false);
    final user = userModel.user;
    final rides = userModel.getRides;
    final vehicles = userModel.getVehicles;

    final foundRide = rides.firstWhere(
          (r) => r.rideId == widget.rideId,
      orElse: () => throw Exception('Ride not found'),
    );
    final foundVehicle = vehicles.firstWhere(
          (v) => v.vehicleId.toString() == foundRide.carId,
      orElse: () => throw Exception('Vehicle not found'),
    );

    setState(() {
      ridetmp = foundRide;
      carName = "${foundVehicle.brand} ${foundVehicle.model}";
    });
    ride = {
      "rideId": ridetmp!.rideId,
      "rideDate": ridetmp?.rideDate,
      "rideTime": ridetmp?.rideTime,
      "numberOfSeat": ridetmp?.numberOfSeat,
      "published": ridetmp?.published,
      "availableSeats": ridetmp?.availableSeats,
      "driverId": user?['userId'],
      "carId": ridetmp!.carId,
      "carName": carName,
      "preferences": ridetmp?.preferences,
      "stopovers": ridetmp?.stopovers.map((s) => {
        "stopoverStatus": s.stopoverStatus,
        "latitude": s.latitude,
        "longitude": s.longitude,
        "name": s.name,
      }).toList(),
      "destination": {
        "status": "PENDING", // Static
        "name": "ENSI"       // Static
      },
      "booking": ridetmp?.booking
          .where((b) => b.bookingStatus == "PENDING")
          .map((b) => {
        "rideId": b.rideId,
        "passengerName": b.passengerName,
        "passengerId": b.passengerId,
        "passengerRate": b.passengerRate,
        "stopoverName": b.stopoverName,
      })
          .toList(),

    };

    print('Found ride: ${ridetmp!.rideId}');
  }




  Future<void> _handleStopoverAction(int index) async {
    final userModel = Provider.of<UserModel>(context, listen: false); // Accès au modèle
    final user = userModel.user; // Accéder à l'utilisateur global
    final token = userModel.token;
    print("Linneeeeeee L index  "+ index.toString());
    print("lTOKEN L FIL DEBUG "+token!);



    final stopover = ride['stopovers'][index];
    final newStatus = stopover['stopoverStatus'] == 'PENDING' ? 'COMPLETED' : 'PENDING';


    try {
      debugPrint('http://localhost:8080/rides/update/${ride['rideId']}');
      final response = await http.put(
        Uri.parse('http://localhost:8080/rides/update/${ride['rideId']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'stopoverIndex': index,
        }),
      );
      if (response.statusCode != 200) {
        print('Failed to update stopover: ${response.body}');
      }

      if (response.statusCode == 200) {

        // Success handling
      } else {
        print("STATUSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
        print(response.statusCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stopover: ${response.body}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating stopover: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      final List<dynamic> stopovers = List.from(ride['stopovers']);
      stopovers[index] = Map<String, dynamic>.from(stopovers[index]);
      stopovers[index]['stopoverStatus'] = newStatus;
      ride['stopovers'] = stopovers;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stopover status updated to ${newStatus.toLowerCase()}'),
        backgroundColor: const Color(0xFF14B8A6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

// Update the _handleDestinationAction method to pass the points to the congratulation dialog
  Future<void> _handleDestinationAction() async {
    final newStatus = ride['destination']['status'] == 'PENDING' ? 'COMPLETED' : 'PENDING';

    // ===== HTTP REQUEST CODE (COMMENTED FOR DEMONSTRATION) =====
    // try {
    //   // Send HTTP POST request
    //   final response = await http.post(
    //     Uri.parse('$baseUrl/destination/update'),
    //     headers: headers,
    //     body: json.encode({
    //       'rideId': ride['rideId'],
    //       'status': newStatus,
    //     }),
    //   );
    //
    //   if (response.statusCode == 200) {
    //     // Success handling would go here
    //   } else {
    //     // Error handling would go here
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Failed to update destination: ${response.body}'),
    //         backgroundColor: Colors.red,
    //         behavior: SnackBarBehavior.floating,
    //       ),
    //     );
    //     return; // Exit without updating UI if request failed
    //   }
    // } catch (e) {
    //   // Exception handling would go here
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Error updating destination: $e'),
    //       backgroundColor: Colors.red,
    //       behavior: SnackBarBehavior.floating,
    //     ),
    //   );
    //   return; // Exit without updating UI if exception occurred
    // }
    // ===== END HTTP REQUEST CODE =====

    // For demonstration, we'll update the UI directly
    setState(() {
      final destination = Map<String, dynamic>.from(ride['destination']);
      destination['status'] = newStatus;
      ride['destination'] = destination;
    });

    // If the ride is completed, show congratulation dialog with points
    if (newStatus == 'COMPLETED') {
      // Calculate points based on ride conditions
      int pointsEarned = 20; // Base points for completing a ride

      // Add 20 points for completing the ride
      setState(() {
        userPoints += pointsEarned;
      });

      // Show congratulation dialog with the actual points earned
      _showCongratulationDialog(pointsEarned);
    } else {
      // Show regular success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Destination status updated to ${newStatus.toLowerCase()}'),
          backgroundColor: const Color(0xFF14B8A6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

// Update the _showCongratulationDialog method to accept points parameter
  void _showCongratulationDialog(int pointsEarned) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have completed your ride successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+$pointsEarned Points',
                        style: TextStyle(
                          color: Colors.teal.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total: $userPoints Points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Great!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Update the _handleBookingAction method to show a congratulation dialog when points are earned
  Future<void> _handleBookingAction(int passengerId, bool accepted) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final token = userModel.token;
    // Find the booking
    final bookings = List.from(ride['booking']);
    final bookingIndex = bookings.indexWhere((b) => b['passengerId'] == passengerId);

    if (bookingIndex == -1) return;

    final passengerName = bookings[bookingIndex]['passengerName'];

    // Calculate points to add (10 if accepted and seats available, 0 otherwise)
    int pointsToAdd = 0;
    if (accepted && ride['availableSeats'] > 0) {
      pointsToAdd = 10;
    }

    // ===== HTTP REQUEST CODE (COMMENTED FOR DEMONSTRATION) =====
     try {
       final headers = {
         'Content-Type': 'application/json',
         'Authorization': 'Bearer $token',
       };
       print("L token   Yehdiykkkkkkkkkkk " + token!);
    //   // Send HTTP POST request
       final response = await http.put(
         Uri.parse("http://localhost:8080/rides/update/${ride['rideId']}/${passengerId}?accept=$accepted"),
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
         },
       );


       if (response.statusCode == 200) {
         // Success handling would go here
       } else {
         // Error handling would go here
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Failed to update booking: ${response.body}'),
             backgroundColor: Colors.red,
             behavior: SnackBarBehavior.floating,
           ),
         );
         return; // Exit without updating UI if request failed
       }
     } catch (e) {
       // Exception handling would go here
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Error updating booking: $e'),
           backgroundColor: Colors.red,
           behavior: SnackBarBehavior.floating,
         ),
       );
       return; // Exit without updating UI if exception occurred
     }

    // ===== END HTTP REQUEST CODE =====

    // For demonstration, we'll update the UI directly
    setState(() {
      // Remove the booking
      bookings.removeAt(bookingIndex);
      ride['booking'] = bookings;

      // Update available seats if accepted
      if (accepted && ride['availableSeats'] > 0) {
        ride['availableSeats'] -= 1;
      }

      // Add points if applicable
      if (pointsToAdd > 0) {
        userPoints += pointsToAdd;
      }
    });

    // If points were added, show a congratulation dialog
    if (pointsToAdd > 0) {
      _showBookingCongratulationDialog(passengerName, pointsToAdd);
    } else {
      // Show feedback message
      final decision = accepted ? 'Accepted' : 'Declined';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$passengerName $decision'),
          backgroundColor: accepted ? const Color(0xFF14B8A6) : Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

// Add a new method for showing booking congratulation dialog
  void _showBookingCongratulationDialog(String passengerName, int pointsEarned) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Booking Accepted!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have accepted $passengerName\'s booking request.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+$pointsEarned Points',
                        style: TextStyle(
                          color: Colors.teal.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total: $userPoints Points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Great!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Update the build method to show total points more prominently
  @override
  Widget build(BuildContext context) {

    final DateTime rideDate = DateTime.parse(ride['rideDate']);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(rideDate);
    final shortDate = DateFormat('MMM d, yyyy').format(rideDate);

    final userModel = Provider.of<UserModel>(context);
    final user = userModel.user;
    final token=userModel.token;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF14B8A6)),
          onPressed: _navigateToMyRides,
        ),
        title: const Text('Ride Details', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
        actions: [
          // Display user points in the app bar with a more prominent design
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FFFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF14B8A6), width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$userPoints Points',
                  style: const TextStyle(
                    color: Color(0xFF0F766E),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ride Info Card
          _buildRideInfoCard(formattedDate, shortDate),
          const SizedBox(height: 16),

          // Preferences Card
          _buildPreferencesCard(),
          const SizedBox(height: 16),

          // Journey Card
          _buildJourneyCard(),
          const SizedBox(height: 16),

          // Bookings Card
          _buildBookingsCard(),
        ],
      ),
    );
  }

  void _handleChatAction(int passengerId, String passengerName) {
    // Navigate to the ChatScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          senderId: ride['driverId'],
          receiverId: passengerId,
          receiverName: passengerName,
        ),
      ),
    );
  }

  // Navigate back to MyRidesScreen
  void _navigateToMyRides() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyRidesScreen(),
      ),
    );
  }

  String _formatLocationName(String name) {
    return name.split(',')[0];
  }

  String _formatTime(String timeString) {
    final parts = timeString.split(':');
    return '${parts[0]}:${parts[1]}';
  }

  Widget _buildRideInfoCard(String formattedDate, String shortDate) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF14B8A6), Color(0xFF10B981)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ride #${ride['rideId']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Added car icon and name
                          const Icon(
                            Icons.directions_car,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ride['carName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Using Container with opacity for simplicity
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Available Seats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${ride['availableSeats']}/${ride['numberOfSeat']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ride Info Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildInfoItem(Icons.access_time_rounded, _formatTime(ride['rideTime'])),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.calendar_today_rounded, shortDate),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.people_alt_rounded, '${ride['availableSeats']} seats left'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF14B8A6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesCard() {
    final List<dynamic> preferences = ride['preferences'];

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF14B8A6)),
                const SizedBox(width: 8),
                const Text(
                  'Ride Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "Driver's preferences for this ride",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preferences.map<Widget>((preference) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FFFA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    preference.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyCard() {
    final List<dynamic> stopovers = ride['stopovers'];

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map_outlined, size: 18, color: Color(0xFF14B8A6)),
                const SizedBox(width: 8),
                const Text(
                  'Journey Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "Route and stopovers",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Fixed Timeline Implementation
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Starting point
                if (stopovers.isNotEmpty)
                  _buildFixedTimelineItem(
                    title: _formatLocationName(stopovers[0]['name']),
                    subtitle: 'Starting Point',
                    isFirst: true,
                    isLast: false,
                    status: stopovers[0]['stopoverStatus'],
                    onPressed: () => _handleStopoverAction(0),
                    buttonText: 'Started',
                  ),

                // Middle stopovers
                for (int i = 1; i < stopovers.length; i++)
                  _buildFixedTimelineItem(
                    title: _formatLocationName(stopovers[i]['name']),
                    subtitle: 'Stopover $i',
                    isFirst: false,
                    isLast: false,
                    status: stopovers[i]['stopoverStatus'],
                    onPressed: () => _handleStopoverAction(1), // lezim ta3tini l id ride w l id passenger
                    buttonText: 'Arrived',
                  ),

                // Destination
                _buildFixedTimelineItem(
                  title: ride['destination']['name'],
                  subtitle: 'Final Destination',
                  isFirst: false,
                  isLast: true,
                  status: ride['destination']['status'],
                  onPressed: _handleDestinationAction,
                  buttonText: 'Reached',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedTimelineItem({
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required String status,
    required VoidCallback onPressed,
    required String buttonText,
  }) {
    Color dotColor;
    if (isFirst) {
      dotColor = Colors.orange;
    } else if (status == 'PENDING') {
      dotColor = const Color(0xFF14B8A6);
    } else {
      dotColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 24,
            height: 60,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isFirst)
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 2,
                      height: 24,
                      color: const Color(0xFFB2F5EA),
                    ),
                  ),
                Positioned(
                  top: 24,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                if (!isLast)
                  Positioned(
                    top: 36,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      height: 24,
                      color: const Color(0xFFB2F5EA),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'PENDING'
                          ? const Color(0xFF14B8A6)
                          : Colors.grey.shade300,
                      foregroundColor: status == 'PENDING'
                          ? Colors.white
                          : Colors.grey.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(buttonText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsCard() {
    final List<dynamic> bookings = ride['booking'];

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 18, color: Color(0xFF14B8A6)),
                const SizedBox(width: 8),
                const Text(
                  'Passenger Bookings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "Manage passenger requests",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            if (bookings.isEmpty)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No bookings yet',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              )
            else
              Column(
                children: bookings.map<Widget>((booking) {
                  // Get passenger rating or default to null
                  final double? passengerRating = booking['passengerRate'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFE6FFFA),
                              child: Text(
                                booking['passengerName'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Passenger info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        booking['passengerName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Chat icon button - Updated to navigate to chat screen
                                      InkWell(
                                        onTap: () => _handleChatAction(
                                            booking['passengerId'],
                                            booking['passengerName']
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE6FFFA),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Icon(
                                            Icons.chat_outlined,
                                            size: 16,
                                            color: Color(0xFF0F766E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pickup: ${_formatLocationName(booking['stopoverName'])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (passengerRating != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // Star rating
                                        _buildRatingStars(passengerRating),
                                        const SizedBox(width: 4),
                                        Text(
                                          passengerRating.toStringAsFixed(1),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.amber.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _handleBookingAction(booking['passengerId'], false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade400,
                                side: BorderSide(color: Colors.red.shade200),
                                backgroundColor: Colors.red.shade50,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Decline',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _handleBookingAction(booking['passengerId'], true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF14B8A6),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Accept',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          // Full star
          return const Icon(Icons.star, size: 14, color: Colors.amber);
        } else if (index == rating.floor() && rating % 1 > 0) {
          // Half star
          return const Icon(Icons.star_half, size: 14, color: Colors.amber);
        } else {
          // Empty star
          return const Icon(Icons.star_border, size: 14, color: Colors.amber);
        }
      }),
    );
  }
}
