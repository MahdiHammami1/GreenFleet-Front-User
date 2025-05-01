import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../models/user_model.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({Key? key}) : super(key: key);

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _seatsController = TextEditingController();

  DateTime _registrationDate = DateTime.now();
  File? _vehicleImage;
  Uint8List? _webImage;
  bool _isLoading = false;

  // List of common car brands for dropdown
  final List<String> _carBrands = [
    'Toyota', 'Honda', 'Ford', 'Chevrolet', 'BMW', 'Mercedes-Benz',
    'Audi', 'Volkswagen', 'Nissan', 'Hyundai', 'Kia', 'Mazda',
    'Subaru', 'Lexus', 'Jeep', 'Tesla', 'Volvo', 'Porsche', 'Other'
  ];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _licenseNumberController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        // For mobile, use File
        setState(() {
          _vehicleImage = File(image.path);
        });
      }
    }
  }

  Future<String?> _uploadVehicleImage(String token, int userId) async {
    if ((_vehicleImage == null && _webImage == null) || token.isEmpty) {
      return null;
    }

    try {
      // Create a multipart request
      final url = Uri.parse('http://localhost:8080/api/vehicles/upload-image');
      final request = http.MultipartRequest('POST', url);

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add user ID as a field
      request.fields['userId'] = userId.toString();

      // Determine file extension and mime type
      String fileExtension = '.jpg';
      if (_vehicleImage != null) {
        fileExtension = path.extension(_vehicleImage!.path).toLowerCase();
      }

      final mimeType = fileExtension == '.png'
          ? 'image/png'
          : fileExtension == '.jpg' || fileExtension == '.jpeg'
          ? 'image/jpeg'
          : 'application/octet-stream';

      // Add the file to the request
      if (kIsWeb && _webImage != null) {
        // For web, use bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _webImage!,
            filename: 'vehicle_image$fileExtension',
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else if (!kIsWeb && _vehicleImage != null) {
        // For mobile, use file path
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _vehicleImage!.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Return the URL of the uploaded image
        return response.body;
      } else {
        print('Failed to upload image: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registrationDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _registrationDate) {
      setState(() {
        _registrationDate = picked;
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userModel = Provider.of<UserModel>(context, listen: false);
      final token = userModel.token;
      final userId = userModel.user?['userId'];

      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Prepare vehicle data
      final vehicleData = {
        'brand': _brandController.text,
        'model': _modelController.text,
        'licenceNumber': _licenseNumberController.text,
        'numberOfSeat': int.parse(_seatsController.text),
        'registrationDate': DateFormat('yyyy-MM-dd').format(_registrationDate),
        'ownerId': userId,
      };

      // Create multipart request
      final uri = Uri.parse('http://localhost:8080/vehicles/add');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add vehicle JSON as a field named 'vehicle'
      request.fields['vehicle'] = jsonEncode(vehicleData);

      // Add image file if available
      if (_vehicleImage != null && !kIsWeb) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',  // This must match the @RequestParam name in your controller
          _vehicleImage!.path,
          contentType: MediaType.parse('image/jpeg'), // Specify content type
        ));
      } else if (_webImage != null && kIsWeb) {
        // For web, use bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',  // This must match the @RequestParam name in your controller
            _webImage!,
            filename: 'vehicle_image.jpg',
            contentType: MediaType.parse('image/jpeg'),
          ),
        );
      } else {
        // No image selected
        throw Exception('Please select a vehicle image');
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Return to previous screen
        Navigator.pop(context, true); // Pass true to indicate refresh needed
      } else {
        throw Exception('Failed to add vehicle: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          'Add Vehicle',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Image
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: _buildVehicleImageWidget(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Brand Dropdown
                _buildDropdownField(
                  label: 'Brand',
                  icon: Icons.branding_watermark,
                  items: _carBrands,
                  onChanged: (value) {
                    if (value != null) {
                      _brandController.text = value;
                    }
                  },
                  validator: (value) {
                    if (_brandController.text.isEmpty) {
                      return 'Please select a brand';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Model Field
                _buildTextField(
                  controller: _modelController,
                  label: 'Model',
                  icon: Icons.model_training,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the model';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // License Number Field
                _buildTextField(
                  controller: _licenseNumberController,
                  label: 'License Number',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the license number';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'License number must be numeric';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Number of Seats Field
                _buildTextField(
                  controller: _seatsController,
                  label: 'Number of Seats',
                  icon: Icons.event_seat,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of seats';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Number of seats must be numeric';
                    }
                    final seats = int.tryParse(value);
                    if (seats == null || seats < 1 || seats > 10) {
                      return 'Number of seats must be between 1 and 10';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Registration Date Field
                _buildDateField(
                  label: 'Registration Date',
                  value: DateFormat('MMM dd, yyyy').format(_registrationDate),
                  icon: Icons.calendar_today,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Save Vehicle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImageWidget() {
    if (_vehicleImage != null && !kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _vehicleImage!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (_webImage != null && kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _webImage!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Add Vehicle Photo',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to select an image',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            icon: Icon(
              icon,
              color: Colors.blue,
              size: 22,
            ),
            border: InputBorder.none,
            errorStyle: const TextStyle(height: 0.5),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  errorStyle: const TextStyle(height: 0.5),
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                value: _brandController.text.isNotEmpty ? _brandController.text : null,
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onChanged,
                validator: validator,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.blue,
                size: 22,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey[400],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}