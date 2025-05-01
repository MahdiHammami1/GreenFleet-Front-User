import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

// Add this class to handle images for both web and mobile
class ProfileImage {
  final File? file; // For mobile
  final Uint8List? webImage; // For web
  final String? path;


  ProfileImage({this.file, this.webImage, this.path});

  bool get isEmpty => file == null && webImage == null;
  bool get isNotEmpty => !isEmpty;
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _imageKey;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;

  ProfileImage? _profileImage;
  bool _isLoading = false;
  String? _profileImageUrl;
  late UserModel _userModel;
  late dynamic _user;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values, will be populated in didChangeDependencies
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch user data from provider
    _userModel = Provider.of<UserModel>(context);
    _user = _userModel.user;

    if (_user != null) {
      // Combine first and last name
      final fullName = "${_user['firstname'] ?? ''} ${_user['lastname'] ?? ''}".trim();
      _nameController.text = fullName;

      // Set email
      _emailController.text = _user['email'] ?? '';

      // Format phone number with country code
      final phone = _user['phoneNumber'] ?? '';
      _phoneController.text = phone.isNotEmpty ? "+216 $phone" : '';

      // Set profile image URL if available
      _profileImageUrl = _user['profilePictureUrl'];

      // You might need to add these fields to your backend
      // For now, using empty or default values
      _locationController.text = "Tunis, Tunisia"; // Default or empty
      _bioController.text = ""; // Default or empty
    }
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
          _profileImage = ProfileImage(
            webImage: bytes,
            path: image.path,
          );
        });
      } else {
        // For mobile, use File
        setState(() {
          _profileImage = ProfileImage(
            file: File(image.path),
            path: image.path,
          );
        });
      }
    }
  }

  Future<String?> _uploadProfileImage(ProfileImage image, String token, int userId) async {
    try {
      // Create a multipart request
      final url = Uri.parse('http://localhost:8080/users/upload/$userId');
      final request = http.MultipartRequest('POST', url);

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Get file extension from path
      final fileExtension = path.extension(image.path ?? '.jpg').toLowerCase();
      final mimeType = fileExtension == '.png'
          ? 'image/png'
          : fileExtension == '.jpg' || fileExtension == '.jpeg'
          ? 'image/jpeg'
          : 'application/octet-stream';

      // Add the file to the request
      if (kIsWeb && image.webImage != null) {
        // For web, use bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            image.webImage!,
            filename: 'profile_image$fileExtension',
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else if (!kIsWeb && image.file != null) {
        debugPrint("ERRRRRRROOOOOORRRRR 0 ");
        // For mobile, use file path
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            image.file!.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else {
        debugPrint("EROOORRRRRRRR 1");
        throw Exception('No valid image data to upload');

      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Return the URL of the uploaded image
        debugPrint("GOOOOOOOOOOOOOOOOD");
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

  Future<bool> _updateUserProfile(Map<String, dynamic> userData, String token) async {
    try {
      final url = Uri.parse('http://localhost:8080/users/${_user['userId']}');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        debugPrint("Jawekkkkkk FISFISSSSSS");
        return true;
      } else {
        debugPrint('Failed to update profile: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Extract first and last name from full name
        final nameParts = _nameController.text.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        // Extract phone number without country code
        final phoneNumber = _phoneController.text.replaceAll('+216 ', '').trim();

        // Get token from user model
        final token = _userModel.token;
        final userId = _user['userId'];

        // Upload profile image if a new one was selected
        String? profilePictureUrl = _user['profilePictureUrl'];
        if (_profileImage != null && _profileImage!.isNotEmpty) {
          final uploadedImageUrl = await _uploadProfileImage(_profileImage!, token!, userId);
          if (uploadedImageUrl != null) {
            profilePictureUrl = uploadedImageUrl;
          }
        }

        // Prepare user data for update
        final userData = {
          'firstname': firstName,
          'lastname': lastName,
          'email': _emailController.text,
          'phoneNumber': phoneNumber,
          'profilePictureUrl': profilePictureUrl,
          // Add other fields as needed
        };

        // Update user profile
        final success = await _updateUserProfile(userData, token!);
        setState(() {
          _imageKey = DateTime.now().toString(); // Generate a new key
        });

        if (success) {
          // Update local user data
          _userModel.updateUser({
            ..._user,
            'firstname': firstName,
            'lastname': lastName,
            'email': _emailController.text,
            'phoneNumber': phoneNumber,
            'profilePictureUrl': profilePictureUrl,
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          Navigator.pop(context);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update profile. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        print('Error saving profile: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildProfileImage(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Form Fields
                  _buildFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  _buildFormField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  _buildFormField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  _buildFormField(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your location';
                      }
                      return null;
                    },
                  ),

                  _buildFormField(
                    controller: _bioController,
                    label: 'Bio',
                    icon: Icons.info_outline,
                    maxLines: 3,
                    validator: (value) {
                      return null; // Bio is optional
                    },
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
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
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    // Handle different image sources based on platform and state
    if (_profileImage != null) {
      if (kIsWeb && _profileImage!.webImage != null) {
        // For web, use memory image
        return Image.memory(
          _profileImage!.webImage!,
          key: ValueKey(_imageKey),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      } else if (!kIsWeb && _profileImage!.file != null) {
        // For mobile, use file image
        return Image.file(
          _profileImage!.file!,
          key: ValueKey(_imageKey),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }
    }

    // If we have a URL, use network image
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      debugPrint("LINNNNEEEEEE");

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      return Image.network(
        'http://localhost:8080/users/image/${_user['userId']}?t=$timestamp', // 👈 cache buster
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        headers: {
          'Authorization': 'Bearer ${_userModel.token}',
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return _buildDefaultAvatar();
        },
      );
    }


    // Default avatar
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
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
              color: colors.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
            icon: Icon(
              icon,
              color: colors.primary,
              size: 22,
            ),
            border: InputBorder.none,
            errorStyle: const TextStyle(height: 0.5),
          ),
          style: theme.textTheme.bodyLarge,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
      ),
    );
  }
}