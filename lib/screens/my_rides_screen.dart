import 'package:flutter/material.dart';
import 'package:flutter_course/screens/ride_details_screen.dart';
import 'package:provider/provider.dart';
import '../models/location_data.dart';
import '../models/ride_screen.dart';
import '../models/stopover_data.dart';
import '../models/user_model.dart';
import 'publish/confirmation_screen.dart';
import 'dart:ui';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({Key? key}) : super(key: key);

  @override
  _MyRidesScreenState createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Format date to a more readable format
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Format time to 12-hour format with AM/PM
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _modifyRide(int index, rides) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(rideData: rides[index]),
      ),
    ).then((_) {
      setState(() {}); // Refresh UI when returning from edit screen
    });
  }

  void _publishRide(int index, rides) {
    setState(() {
      rides[index].published = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              "Ride Published Successfully!",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A8270),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final user = userModel.user;
    final List<RideData> rides = userModel.getRides.map((rideDTO) {
      // Parse the date string to DateTime
      final dateParts = rideDTO.rideDate.split('-');
      final DateTime rideDate = DateTime(
        int.parse(dateParts[0]),  // year
        int.parse(dateParts[1]),  // month
        int.parse(dateParts[2]),  // day
      );
      final driverId= user?['userId'];

      // Parse the time string to TimeOfDay
      final timeParts = rideDTO.rideTime.split(':');
      final TimeOfDay rideTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );

      // Convert stopovers
      final List<Stopovers> convertedStopovers = rideDTO.stopovers.map((stopoverDTO) {
        return Stopovers(
          location: Location(
            latitude: stopoverDTO.latitude,
            longitude: stopoverDTO.longitude,
            nameLocation: stopoverDTO.name,
          ),
          stopoverStatus: stopoverDTO.stopoverStatus,
        );
      }).toList();

      // Create and return the RideData object
      return RideData(
        rideId: rideDTO.rideId,
        driverId:user?['userId'],
        carId: int.tryParse(rideDTO.carId),
        rideDate: rideDate,
        rideTime: rideTime,
        numberOfSeat: rideDTO.numberOfSeat,
        published: rideDTO.published,
        stopovers: convertedStopovers,
        preferences: rideDTO.preferences,
      );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "My Rides",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: rides.isEmpty
          ? _buildEmptyState()
          : AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              // Staggered animation for list items
              final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    index * 0.1,
                    index * 0.1 + 0.5,
                    curve: Curves.easeOut,
                  ),
                ),
              );

              return FadeTransition(
                opacity: itemAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.2, 0),
                    end: Offset.zero,
                  ).animate(itemAnimation),
                  child: _buildRideCard(ride, index,rides),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No rides yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideData ride, int index,rides) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with gradient and status
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ride.published
                    ? [const Color(0xFF0A8270), const Color(0xFF1E6F7C)]
                    : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      ride.published ? Icons.check_circle : Icons.pending_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ride.published ? "Published" : "Draft",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  ride.rideDate != null ? _formatDate(ride.rideDate!) : "N/A",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time and Seats Row
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.access_time_rounded,
                      ride.rideTime != null ? _formatTime(ride.rideTime!) : "N/A",
                      "Departure Time",
                    ),
                    const SizedBox(width: 24),
                    _buildInfoItem(
                      Icons.airline_seat_recline_normal_rounded,
                      "${ride.numberOfSeat ?? 0}",
                      "Available Seats",
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preferences
                if (ride.preferences.isNotEmpty) ...[
                  const Text(
                    "Preferences",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ride.preferences.map((pref) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pref,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0A8270),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                if (!ride.published)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        "Modify",
                        Icons.edit_outlined,
                        const Color(0xFF64748B),
                            () => _modifyRide(index,rides),
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        "Publish",
                        Icons.publish_rounded,
                        const Color(0xFF0A8270),
                            () => _publishRide(index,rides),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        "View Details",
                        Icons.visibility_outlined,
                        const Color(0xFF0A8270),
                         () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => RideDetailsScreen(rideId: ride.rideId!),
                             ),
                           );



                        },
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

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF0A8270),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}