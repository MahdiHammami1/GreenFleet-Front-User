import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// User model reference (assuming this exists in your project)
import '../models/user_model.dart';

// Badge type enum
enum BadgeType {
  BRONZE,
  SILVER,
  GOLD,
}

class BadgesPage extends StatefulWidget {
  const BadgesPage({Key? key}) : super(key: key);

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> _badges = [];

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  // API call to fetch badges
  Future<void> _loadBadges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = Provider.of<UserModel>(context, listen: false).user;
      final token = Provider.of<UserModel>(context, listen: false).token;

      if (user == null || token == null) {
        throw Exception('User not authenticated');
      }

      // Get userId safely
      dynamic userId;
      if (user.containsKey('userId')) {
        userId = user['userId'];
      } else if (user.containsKey('id')) {
        userId = user['id'];
      } else {
        // Try to find any key that might contain the user ID
        final possibleIdKeys = ['id', 'userId', 'user_id', 'ID', 'Id'];
        for (final key in possibleIdKeys) {
          if (user.containsKey(key)) {
            userId = user[key];
            break;
          }
        }

        if (userId == null) {
          throw Exception('User ID not found in user object');
        }
      }

      // Make API call
      final baseUrl = 'http://localhost:8080'; // Replace with your actual API URL
      final url = Uri.parse('$baseUrl/users/$userId/badges');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response as a list of strings
        final List<dynamic> badgesJson = jsonDecode(response.body);
        final badges = badgesJson.map((badge) => badge.toString()).toList();

        setState(() {
          _badges = badges;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to load badges. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
          'My Achievements',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF98D2C0)))
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load badges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBadges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98D2C0),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      )
          : _badges.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No badges yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete tasks to earn your first badge!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Achievements',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have earned ${_badges.length} badge${_badges.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildBadgeSummary(),
                  const SizedBox(height: 24),
                  const Text(
                    'All Badges',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _badges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(_badges[index]);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeSummary() {
    final bronzeCount = _badges.where((b) => b.toUpperCase() == 'BRONZE').length;
    final silverCount = _badges.where((b) => b.toUpperCase() == 'SILVER').length;
    final goldCount = _badges.where((b) => b.toUpperCase() == 'GOLD').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBadgeTypeCount(
            icon: Icons.emoji_events,
            color: const Color(0xFFCD7F32), // Bronze
            count: bronzeCount,
            label: 'Bronze',
          ),
          _buildBadgeTypeCount(
            icon: Icons.emoji_events,
            color: const Color(0xFFC0C0C0), // Silver
            count: silverCount,
            label: 'Silver',
          ),
          _buildBadgeTypeCount(
            icon: Icons.emoji_events,
            color: const Color(0xFFFFD700), // Gold
            count: goldCount,
            label: 'Gold',
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTypeCount({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              icon,
              color: color,
              size: 32,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String badgeType) {
    // Get badge details based on the badge type string
    final details = _getBadgeDetails(badgeType);

    return GestureDetector(
      onTap: () => _showBadgeDetails(badgeType),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: details.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                details.icon,
                color: details.color,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              details.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                details.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: details.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeType.toUpperCase(),
                style: TextStyle(
                  color: details.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(String badgeType) {
    final details = _getBadgeDetails(badgeType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F4F9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: details.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        details.icon,
                        color: details.color,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      details.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: details.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        badgeType.toUpperCase(),
                        style: TextStyle(
                          color: details.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
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
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            details.description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Earned On',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat('MMMM d, yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Share badge functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Badge shared successfully!'),
                            backgroundColor: Color(0xFF98D2C0),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share Achievement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF98D2C0),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




  // Helper method to get badge details based on badge type string
  BadgeDetails _getBadgeDetails(String badgeType) {
  switch (badgeType.toUpperCase()) {
  case 'BRONZE':
  return BadgeDetails(
  name: 'Bronze Rider',
  description: 'Completed 10+ rides with excellent ratings',
  icon: Icons.workspace_premium,
  color: const Color(0xFFCD7F32),
  );
  case 'SILVER':
  return BadgeDetails(
  name: 'Silver Rider',
  description: 'Completed 50+ rides with excellent ratings',
  icon: Icons.emoji_events,
  color: const Color(0xFFC0C0C0),
  );
  case 'GOLD':
  return BadgeDetails(
  name: 'Gold Rider',
  description: 'Completed 100+ rides with excellent ratings',
  icon: Icons.military_tech,
  color: const Color(0xFFFFD700),
  );
  default:
  return BadgeDetails(
  name: badgeType,
  description: 'Special achievement',
  icon: Icons.verified,
  color: Colors.blue,
  );
  }
  }
}
class BadgeDetails {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  BadgeDetails({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}