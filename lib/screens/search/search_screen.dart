import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_course/screens/search/result_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/Ride_Response_dart.dart';
import '../../models/user_model.dart';
import '../home_screen.dart';
import '../location_picker_screen.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '/models/ride_searched_data.dart';
import '/models/location_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FindRidePage extends StatefulWidget {
  const FindRidePage({Key? key}) : super(key: key);

  @override
  _FindRidePageState createState() => _FindRidePageState();
}

class _FindRidePageState extends State<FindRidePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  GeoPoint? _fromLocation;
  double _tolerantDistance = 1.0;
  AlternativeType? _selectedAlternative;
  String? _selectedCarModel;
  List<String> carModels = ['BMW', 'i10', 'Kia Sportage', 'Peugeot 206', 'Clio Bombé'];//**************** Hethi mel Base **********************************

  // Color scheme
  final Color primaryColor = const Color(0xFF1b4242);
  final Color accentColor = const Color(0xFF5C8374);
  final Color backgroundColor = Colors.white;
  final Color cardColor = const Color(0xFFF5F5F5);
  final Color textColor = const Color(0xFF333333);
  final Color subtitleColor = const Color(0xFF666666);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          title: 'Select Starting Point',
        ),
      ),
    );

    if (result != null && result is Location) {
      setState(() {
        _fromLocation = GeoPoint(
          latitude: result.latitude,
          longitude: result.longitude,
        );
        _fromController.text = result.nameLocation;
      });
    }
  }

  // Import the dart:convert package for JSON formatting

  void _handleFindRide() async {
    debugPrint("HANDLE FIND RIDE CALLED");
    debugPrint("HANDLE FIND RIDE CALLED");

    final userModel = Provider.of<UserModel>(context, listen: false);
    final token = userModel.token;


    if (_selectedDate == null || _selectedTime == null || _fromLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }


    try {

      // Create RideSearchedData
      final rideData = RideSearchedData(
        fromLocation: Location(
          nameLocation: _fromController.text,
          latitude: _fromLocation!.latitude,
          longitude: _fromLocation!.longitude,
        ),
        date: _selectedDate!,
        time: _selectedTime!,
        rayonPossible: _tolerantDistance,
        alternativeType: _selectedAlternative,
        car: _selectedAlternative == AlternativeType.car
            ? Car(
          model: _selectedCarModel ?? "",
          age: int.tryParse(_ageController.text) ?? 0,
        )
            : null,
      );

      // Serialize to JSON
      final jsonData = jsonEncode(rideData.toJson());

      // Log JSON Data for Debugging
      debugPrint("Sending JSON Data: $jsonData");

      // Send POST Request
      final response = await http.post(
        Uri.parse('http://localhost:8080/rides/searchRides'), // Replace with your actual API URL
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonData,
      );

      // Handle Response
      if (response.statusCode == 200) {
        debugPrint("Response: ${response.body}");
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<RideResponse> rides = responseData
            .map((rideJson) => RideResponse.fromJson(rideJson))
            .toList();

        // Navigate to ResultScreen with fetched data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(rideResults: rides),
          ),
        );
      } else {
        debugPrint("Error Response: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch rides: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Find a Ride',
          style: TextStyle(
            color: Color(0xFF1b4242),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 22),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          /*decoration: BoxDecoration(
            color: backgroundColor,
            image: DecorationImage(
              image: AssetImage('lib/images/sn.png'), // Correct way to load asset image
              opacity: 0.05,
              fit: BoxFit.cover,
            ),
          ),*/

          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                  child: Text(
                    "Where are you going?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),

                // Location card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DEPARTURE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: _selectLocation,
                        child: IgnorePointer(
                          child: _buildTextField(
                            controller: _fromController,
                            label: 'Leaving from',
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Date and time card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SCHEDULE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: IgnorePointer(
                                child: _buildTextField(
                                  controller: _dateController,
                                  label: 'Date',
                                  icon: Icons.calendar_today,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context),
                              child: IgnorePointer(
                                child: _buildTextField(
                                  controller: _timeController,
                                  label: 'Time',
                                  icon: Icons.access_time,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Distance preference card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DISTANCE PREFERENCE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tolerant Distance',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_tolerantDistance.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: primaryColor,
                          trackHeight: 4,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: _tolerantDistance,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          onChanged: (value) {
                            setState(() {
                              _tolerantDistance = value;
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1 km', style: TextStyle(color: subtitleColor, fontSize: 12)),
                          Text('5 km', style: TextStyle(color: subtitleColor, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Transportation options card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TRANSPORTATION",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildDropdownField(
                        value: _selectedAlternative,
                        items: AlternativeType.values.map((alt) {
                          return DropdownMenuItem<AlternativeType>(
                            value: alt,
                            child: Row(
                              children: [
                                Icon(
                                  _getIconForAlternative(alt),
                                  color: primaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  _getNameForAlternative(alt),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAlternative = value;
                            if (value != AlternativeType.car) {
                              _selectedCarModel = null;
                              _ageController.clear();
                            }
                          });
                        },
                        label: 'Transportation Type',
                      ),

                      if (_selectedAlternative == AlternativeType.car) ...[
                        SizedBox(height: 15),
                        _buildDropdownField(
                          value: _selectedCarModel,
                          items: carModels.map((model) {
                            return DropdownMenuItem<String>(
                              value: model,
                              child: Text(
                                model,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCarModel = value;
                            });
                          },
                          label: 'Car Model',
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _ageController,
                          label: 'Car Age (years)',
                          icon: Icons.calendar_view_month,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Find Ride Button
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleFindRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Find a Ride',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subtitleColor, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
    );
  }

  // Helper method to build consistent dropdown fields
  Widget _buildDropdownField<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String label,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subtitleColor, fontSize: 14),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      icon: Icon(Icons.arrow_drop_down, color: primaryColor),
      dropdownColor: Colors.white,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
    );
  }

  // Helper method to build consistent cards
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // Helper method to get icon for alternative type
  IconData _getIconForAlternative(AlternativeType type) {
    switch (type) {
      case AlternativeType.car:
        return Icons.directions_car;
      case AlternativeType.bus:
        return Icons.directions_bus;

      default:
        return Icons.commute;
    }
  }

  // Helper method to get friendly name for alternative type
  String _getNameForAlternative(AlternativeType type) {
    switch (type) {
      case AlternativeType.car:
        return "Car";
      case AlternativeType.bus:
        return "Bus";

      default:
        return type.toString().split('.').last;
    }
  }
}

/* lclass mta3 e données eli bech yousseli esmou ride_searched_data */