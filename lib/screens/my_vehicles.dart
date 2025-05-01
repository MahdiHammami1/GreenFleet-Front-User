import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../models/user_model.dart';
import 'addVehiclepage_screen.dart';


class VehicleDTO {
  final int vehicleId;
  final int licenceNumber;
  final String brand;
  final String model;
  final int numberOfSeat;
  final DateTime registrationDate;
  final String? pictureUrl;
  final int ownerId;

  VehicleDTO({
    required this.vehicleId,
    required this.licenceNumber,
    required this.brand,
    required this.model,
    required this.numberOfSeat,
    required this.registrationDate,
    this.pictureUrl,
    required this.ownerId,
  });

  factory VehicleDTO.fromJson(Map<String, dynamic> json) {
    return VehicleDTO(
      vehicleId: json['vehicleId'],
      licenceNumber: json['licenceNumber'],
      brand: json['brand'],
      model: json['model'],
      numberOfSeat: json['numberOfSeat'],
      registrationDate: DateTime.parse(json['registrationDate']),
      pictureUrl: json['pictureUrl'],
      ownerId: json['ownerId'],
    );
  }
}

class MyVehiclesPage extends StatefulWidget {
  const MyVehiclesPage({Key? key}) : super(key: key);

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  late Future<List<VehicleDTO>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = _fetchVehicles();
  }

  Future<List<VehicleDTO>> _fetchVehicles() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final token = userModel.token;
    final userId = userModel.user?['userId'];
    print(userId);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/users/$userId/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> vehiclesJson = json.decode(response.body);
        return vehiclesJson.map((json) => VehicleDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load vehicles: $e');
    }
  }

  Future<void> _refreshVehicles() async {
    setState(() {
      _vehiclesFuture = _fetchVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Vehicles',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              // Navigate to add vehicle page and wait for result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddVehiclePage()),
              );

              // If result is true, refresh the vehicles list
              if (result == true) {
                _refreshVehicles();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVehicles,
        child: FutureBuilder<List<VehicleDTO>>(
          future: _vehiclesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddVehiclePage()),
                        );

                        if (result == true) {
                          _refreshVehicles();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Vehicle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/no_vehicle.png',
                      height: 200,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Vehicles Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add your first vehicle to start sharing rides',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to add vehicle page
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Vehicle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final vehicles = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return buildVehicleCard(vehicle);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildVehicleCard(VehicleDTO vehicle) {
    // Construct the image URL using the endpoint
    final imageUrl = 'http://localhost:8080/image/${vehicle.vehicleId}';

    // Debug print to check the URL
    print('Loading vehicle image from: $imageUrl');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: FutureBuilder<Uint8List?>(
                future: _fetchVehicleImage(vehicle.vehicleId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    print('Error loading image: ${snapshot.error}');
                    return _buildPlaceholderImage(vehicle.brand);
                  } else {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
            ),
          ),

          // Vehicle Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${vehicle.numberOfSeat} seats',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.credit_card, 'License: ${vehicle.licenceNumber}'),
                const SizedBox(height: 4),
                _buildInfoRow(
                    Icons.calendar_today,
                    'Registered: ${DateFormat('MMM d, yyyy').format(vehicle.registrationDate)}'
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      onPressed: () {
                        // Handle edit
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      onPressed: () {
                        _showDeleteConfirmation(vehicle);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
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

// Add this method to fetch the image data
  Future<Uint8List?> _fetchVehicleImage(int vehicleId) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final token = userModel.token;
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/vehicles/image/$vehicleId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }
  Widget _buildPlaceholderImage(String brand) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            '$brand',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(VehicleDTO vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle?'),
        content: Text(
          'Are you sure you want to delete your ${vehicle.brand} ${vehicle.model}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteVehicle(vehicle.vehicleId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(int vehicleId) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final token = userModel.token;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/vehicles/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the list
        _refreshVehicles();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete vehicle: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete vehicle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}