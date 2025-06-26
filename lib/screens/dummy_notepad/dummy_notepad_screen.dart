import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';

class QuickExitSettingsScreen extends StatefulWidget {
  const QuickExitSettingsScreen({Key? key}) : super(key: key);

  @override
  State<QuickExitSettingsScreen> createState() =>
      _QuickExitSettingsScreenState();
}

class _QuickExitSettingsScreenState extends State<QuickExitSettingsScreen> {
  bool _quickExitEnabled = false;
  String _password = '';
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _quickExitEnabled = prefs.getBool('quickExitEnabled') ?? false;
      _password = prefs.getString('quickExitPassword') ?? '';
      _passwordController.text = _password;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quickExitEnabled', _quickExitEnabled);
    await prefs.setString('quickExitPassword', _password);
  }

  void _toggleQuickExit(bool value) {
    setState(() {
      _quickExitEnabled = value;
    });
    _saveSettings();
  }

  void _updatePassword() {
    setState(() {
      _password = _passwordController.text;
    });
    _saveSettings();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Password updated successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Exit Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Exit Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'When enabled, the app will appear as a notepad when reopened. Enter your password to access the real app.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Enable Quick Exit'),
                        Spacer(),
                        Switch(
                          value: _quickExitEnabled,
                          onChanged: _toggleQuickExit,
                          activeColor: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter a password to unlock the app when in quick exit mode.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.save),
                          onPressed: _updatePassword,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('quickExitPassword');
                        await prefs.setBool('quickExitEnabled', false);
                        setState(() {
                          _password = '';
                          _quickExitEnabled = false;
                          _passwordController.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Password reset. Quick exit disabled.',
                            ),
                          ),
                        );
                      },
                      child: Text('Forgot Password? Reset'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Exit Button',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the button below to immediately exit the app. When you reopen it, it will appear as a notepad.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _quickExitEnabled
                            ? () async {
                                await _saveSettings();
                                SystemNavigator.pop();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Quick Exit'),
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
}

class DummyNotepadScreen extends StatefulWidget {
  const DummyNotepadScreen({Key? key}) : super(key: key);

  @override
  State<DummyNotepadScreen> createState() => _DummyNotepadScreenState();
}

class _DummyNotepadScreenState extends State<DummyNotepadScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  String _savedPassword = '';

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPassword = prefs.getString('quickExitPassword') ?? '';
    });
  }

  void _checkPassword() {
    if (_controller.text.trim() == _savedPassword &&
        _savedPassword.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _error = 'Incorrect password. This is just a notepad.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notepad'),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type your notes here...',
                  border: OutlineInputBorder(),
                  errorText: _error,
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _checkPassword, child: Text('Save')),
            SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('quickExitPassword');
                await prefs.setBool('quickExitEnabled', false);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: Text('Forgot Password? Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
