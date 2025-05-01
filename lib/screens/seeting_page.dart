import 'package:flutter/material.dart';
import 'package:flutter_course/screens/password_modification_screen.dart';
import 'package:flutter_course/screens/rate_application_screen.dart';
import 'package:flutter_course/screens/refferal_page_screen.dart';

import 'delete_account_dialogue_screen.dart';
import 'logout_dialogue_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text(
            'Settings & Help',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.lock,
                iconColor: Colors.blue,
                title: 'Password Modification',
                subtitle: 'Modify your password if needed.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PasswordModificationScreen()),
                  );
                },
              ),

              _buildSettingItem(
                icon: Icons.star,
                iconColor: Colors.blue,
                title: 'Rate the Application',
                subtitle: 'We deserve 5 stars, right? :)',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RateApplicationScreen()),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.link,
                iconColor: Colors.blue,
                title: 'Referral Code',
                subtitle: 'Generate a referral code',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReferralCodeScreen()),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.list,
                iconColor: Colors.blue,
                title: 'Terms and Conditions',
                subtitle: 'Read the T&C',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.shield,
                iconColor: Colors.blue,
                title: 'Privacy Policy',
                subtitle: 'Read the Privacy Policy',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.delete,
                iconColor: Colors.blue,
                title: 'Delete Account',
                subtitle: 'Fill out the form',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => DeleteAccountDialog(
                      onConfirm: () {
                        Navigator.pop(context);
                        // Add account deletion logic here
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.exit_to_app,
                iconColor: Colors.blue,
                title: 'Log Out',
                subtitle: 'See you soon',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => LogoutDialog(
                      onConfirm: () {
                        Navigator.pop(context);
                        // Add logout logic here
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}