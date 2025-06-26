import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionUtil {
  static Future<bool> checkAndRequestLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.location.request();
    return result.isGranted;
  }

  static Future<bool> checkAndRequestPhonePermission() async {
    final status = await Permission.phone.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.phone.request();
    return result.isGranted;
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      // Remove any spaces or special characters but keep the original format
      final formattedNumber = phoneNumber.trim();
      
      // Create the URI with the tel scheme
      final Uri phoneUri = Uri.parse('tel:$formattedNumber');
      
      // Launch the dialer with the phone number
      if (!await launchUrl(phoneUri)) {
        throw Exception('Could not launch phone dialer');
      }
    } catch (e) {
      throw Exception('Could not launch phone dialer: $e');
    }
  }
} 