import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/base_scaffold.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final statuses = await Future.wait([
      Permission.location.status,
      Permission.locationAlways.status,
      Permission.phone.status,
    ]);

    setState(() {
      _permissionStatuses = {
        Permission.location: statuses[0],
        Permission.locationAlways: statuses[1],
        Permission.phone: statuses[2],
      };
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      _permissionStatuses[permission] = status;
    });
  }

  String _getPermissionText(Permission permission) {
    switch (permission) {
      case Permission.location:
        return 'Location Access';
      case Permission.locationAlways:
        return 'Background Location';
      case Permission.phone:
        return 'Phone Calls';
      default:
        return 'Unknown Permission';
    }
  }

  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.location:
        return 'Required to find nearby emergency contacts';
      case Permission.locationAlways:
        return 'Allows continuous location tracking for emergency features';
      case Permission.phone:
        return 'Required to make emergency calls directly from the app';
      default:
        return '';
    }
  }

  Widget _buildPermissionTile(Permission permission) {
    final status = _permissionStatuses[permission];
    final isGranted = status?.isGranted ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPermissionText(permission),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getPermissionDescription(permission),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isGranted,
                  onChanged: (value) {
                    if (value) {
                      _requestPermission(permission);
                    } else {
                      openAppSettings();
                    }
                  },
                  activeColor: Color(0xFF7C3AED),
                ),
              ],
            ),
            if (status?.isPermanentlyDenied ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Permission permanently denied. Please enable in device settings.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Color(0xFF7C3AED), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'General Settings',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Manage app permissions to ensure all features work correctly. Some features may not work without the required permissions.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _buildPermissionTile(Permission.location),
                  _buildPermissionTile(Permission.locationAlways),
                  _buildPermissionTile(Permission.phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 