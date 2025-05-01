import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_course/screens/seeting_page.dart';


import 'badges_page.dart';
import 'edit_profile_screen.dart';
import 'my_vehicles.dart';
class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rider Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A80F0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A80F0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF1E1E1E),
        ),
      ),
      themeMode: ThemeMode.light,
      useInheritedMediaQuery: true,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final String name = "Aziz Moussi";
  final String location = "Tunis, Tunisia";
  final double rating = 4.8;
  final int rides = 52;
  final int points = 3200;

  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280, // Reduced height to prevent overflow
            pinned: true,
            backgroundColor: colors.primary,
            elevation: 0,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              title: const SizedBox.shrink(),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF98D2C0),
                      Color(0xFF4F959D),
                    ],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Use LayoutBuilder to get available space
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min, // Use min size to prevent overflow
                        children: [
                          const SizedBox(height: 16),
                          Hero(
                            tag: 'profile-avatar',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 45, // Reduced size
                                backgroundColor: Colors.white,
                                child: _buildAvatar(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8), // Reduced spacing
                          Text(
                            name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.9)),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Reduced spacing
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Reduced padding
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStat(context, Icons.star, "$rating", "Rating", Colors.white),
                                _buildVerticalDivider(),
                                _buildStat(context, Icons.directions_car, "$rides", "Rides", Colors.white),
                                _buildVerticalDivider(),
                                _buildStat(context, Icons.emoji_events, "$points", "Points", Colors.white),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16), // Reduced spacing
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeInAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeInAnimation.value,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 16),
                      child: Text(
                        "Profile",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildAction(
                      context,
                      Icons.edit_document,
                      "Edit Profile",
                      "Update your personal information",
                      const Color(0xFF4A80F0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        );
                      },
                    ),
                    _buildAction(
                      context,
                      Icons.verified,
                      "My Badges",
                      "View your achievements",
                      const Color(0xFFFFA726),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BadgesPage()),
                        );
                      },
                    ),
                    _buildAction(
                      context,
                      Icons.directions_car,
                      "My Vehicles",
                      "Manage your registered vehicles",
                      const Color(0xFF42A5F5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyVehiclesPage()),
                        );
                      },
                    ),
                    _buildAction(
                      context,
                      Icons.history,
                      "Ride History",
                      "View your past rides",
                      const Color(0xFF7E57C2),
                      onTap: () {},
                    ),
                    _buildAction(
                      context,
                      Icons.settings,
                      "Settings",
                      "App preferences and notifications",
                      const Color(0xFF78909C),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle image loading with error handling
  Widget _buildAvatar() {
    return ClipOval(
      child: Image.asset(
        'images/photo.png', // Use a local asset as fallback
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Show a placeholder on error
          return Container(
            width: 90,
            height: 90,
            color: Colors.grey.shade300,
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.grey.shade700,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24, // Reduced height
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use min size to prevent overflow
        children: [
          Icon(icon, size: 16, color: color), // Reduced size
          const SizedBox(height: 2), // Reduced spacing
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16, // Reduced font size
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
              fontSize: 10, // Reduced font size
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      Color color,
      {required VoidCallback onTap}
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Reduced margin
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
            child: Row(
              children: [
                Container(
                  width: 40, // Reduced size
                  height: 40, // Reduced size
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20), // Reduced size
                ),
                const SizedBox(width: 12), // Reduced spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Reduced font size
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12, // Reduced font size
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  size: 20, // Reduced size
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}