import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/chatbot_fab.dart';
import 'provider/auth_provider.dart';
import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _otpSent = false;
  String? _email;

  Widget _buildOtpInput() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  FocusScope.of(context).nextFocus();
                }
                String otp = '';
                // Combine all digits
                for (var i = 0; i < 6; i++) {
                  final controller = TextEditingController();
                  if (i == index) {
                    otp += value;
                  } else {
                    // Get value from other fields
                    if (_otpController.text.length > i) {
                      otp += _otpController.text[i];
                    }
                  }
                }
                _otpController.text = otp;
              },
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(child: Image.asset('assets/gbvshield.png', width: 80)),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _otpSent ? 'Reset Password' : 'Forgot Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _otpSent
                      ? 'Enter the OTP sent to your email'
                      : 'Enter your email to receive a reset code',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              if (!_otpSent) ...[
                Text('Email*', style: TextStyle(fontWeight: FontWeight.w500)),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ] else ...[
                Text('OTP Code*', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildOtpInput(),
                const SizedBox(height: 16),
                Text('New Password*', style: TextStyle(fontWeight: FontWeight.w500)),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Confirm Password*', style: TextStyle(fontWeight: FontWeight.w500)),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_error!, style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7C3AED),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });

                        if (!_otpSent) {
                          final success = await authProvider.requestPasswordReset(
                            _emailController.text,
                          );
                          setState(() {
                            _loading = false;
                            if (success) {
                              _otpSent = true;
                              _email = _emailController.text;
                            } else {
                              _error = authProvider.error ?? 'Failed to send OTP';
                            }
                          });
                        } else {
                          if (_passwordController.text != _confirmPasswordController.text) {
                            setState(() {
                              _loading = false;
                              _error = 'Passwords do not match';
                            });
                            return;
                          }

                          final success = await authProvider.resetPassword(
                            _email!,
                            _otpController.text,
                            _passwordController.text,
                          );

                          setState(() => _loading = false);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Password reset successful')),
                            );
                            Navigator.pushReplacementNamed(context, '/login');
                          } else {
                            setState(() => _error = authProvider.error ?? 'Failed to reset password');
                          }
                        }
                      },
                child: _loading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _otpSent ? 'Reset Password' : 'Send Reset Code',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Remember your password? ",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const ChatbotFAB(),
    );
  }
} 