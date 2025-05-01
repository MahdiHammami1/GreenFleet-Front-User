import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/progress_indicator.dart';

import 'steps/password_step.dart';
import 'steps/name_step.dart';
import 'steps/phone_step.dart' as phone;
import 'steps/dob_step.dart';
import 'steps/preference_step.dart';
import 'steps/verification_step.dart';
import 'home_screen.dart';
import 'steps/email_step.dart';
import '/models/user_data.dart';

class SignUpFlow extends StatefulWidget {
  @override
  _SignUpFlowState createState() => _SignUpFlowState();
}

class _SignUpFlowState extends State<SignUpFlow> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final Color primaryColor = const Color(0xFF1B4242);

  final UserData userData = UserData();


  void nextPage() {
    if (currentPage < 6) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentPage++);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentPage--);
    }
  }

  // Dummy method to simulate signup without backend
  Future<void> submitSignup() async {


    final url = Uri.parse('http://localhost:8080/auth/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData.toJson()),
      );

      if (response.statusCode == 200) {
        nextPage();
      } else {
        print('Server responded: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
    // ✅ Don't forget this!

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Sign Up",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: LinearProgressIndicator(
              value: (currentPage + 1) / 7,
              backgroundColor: primaryColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 5,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                EmailStep(
                  onNext: (email) {
                    userData.email = email;
                    nextPage();
                  },
                ),
                PasswordStep(
                  onNext: (password) {
                    userData.password = password;
                    nextPage();
                  },
                  onBack: previousPage,
                ),
                NameStep(
                  onNext: (firstName, lastName) {
                    userData.firstname = firstName;
                    userData.lastname = lastName;
                    nextPage();
                  },
                  onBack: previousPage,
                ),
                phone.PhoneStep(
                  onNext: (phoneNumber) {
                    userData.phoneNumber = phoneNumber;
                    nextPage();
                  },
                  onBack: previousPage,
                ),
                DobStep(
                  onNext: (dob) {
                    userData.dateOfBirth = dob;
                    nextPage();
                  },
                  onBack: previousPage,
                ),
                PreferenceStep(
                  onSubmit: (preferences) {
                    userData.gender = (preferences == "Mr.") ? "Male" : "Female";
                    submitSignup();
                  },
                  onBack: previousPage,
                ),
                VerificationStep(
                  onSubmit: (code) async {
                    /*final url = Uri.parse('http://localhost:8080/auth/verify');
                     final body = {
                       'email': userData.email,
                       'verificationCode': code,
                     };

                     try {
                       final response = await http.post(
                         url,
                         headers: {'Content-Type': 'application/json'},
                         body: jsonEncode(body),
                       );

                      if (response.statusCode == 200) {*/
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                    /*   } else {
                         print('Verification failed: ${response.body}');
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Verification failed. Please check the code.')),
                         );
                       }
                     } catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('An error occurred during verification.')),
                       );
                     } */
                  },
                  onBack: previousPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

