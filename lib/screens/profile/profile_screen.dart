import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/base_scaffold.dart';
import 'my_reports_screen.dart';
import '../auth/provider/auth_provider.dart';
import '../home/saved_stories_screen.dart';
import '../settings/general_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return BaseScaffold(
      currentIndex: 3,
      onTab: (i) {
        if (i == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (i == 1) {
          Navigator.pushReplacementNamed(context, '/learn');
        } else if (i == 2) {
          Navigator.pushReplacementNamed(context, '/report');
        } else if (i == 3) {
          // Already on profile
        }
      },
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Custom AppBar
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 8, left: 0, right: 0, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.person, color: Color(0xFF7C3AED), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            // Emergency Support Alert
            Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFFE0E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFFFB4B4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Support',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "If you're in immediate danger, contact emergency services or use the quick exit feature.",
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // User Info
            Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF7C3AED).withOpacity(0.1),
                    child: Image.asset(
                      'assets/Avatar.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Anonymous User',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user != null ? 'ID: ${user.id}' : '',
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Your identity is protected',
                      style: TextStyle(color: Color(0xFF7C3AED), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            // Safety & Privacy
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
              child: Text(
                'Safety & Privacy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Emergency Contacts'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/report',
                        arguments: {'tab': 0}, // 0 is the emergency contacts tab
                      );
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text('Quick Exit Settings'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, '/dummyNotepad');
                    },
                  ),
                ],
              ),
            ),
            // Support & Resources
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
              child: Text(
                'Support & Resources',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    title: Text('My Reports'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyReportsScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text('Saved Resources'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedStoriesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // App Settings
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
              child: Text(
                'App Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              margin: EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  ListTile(
                    title: Text('General Settings'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GeneralSettingsScreen(),
                        ),
                      );
                    },
                  ),
                
                  Divider(height: 1),
                  ListTile(
                    title: Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: Icon(Icons.logout, color: Colors.red, size: 20),
                    onTap: () async {
                      try {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (Route<dynamic> route) => false,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to logout. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
