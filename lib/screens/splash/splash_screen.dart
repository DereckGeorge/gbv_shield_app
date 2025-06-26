import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait for auth provider to initialize
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    // Check if user is logged in
    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/gbvshield.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFF7C3AED),
            ),
          ],
        ),
      ),
    );
  }
}
