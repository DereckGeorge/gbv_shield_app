import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/provider/auth_provider.dart';
import 'screens/home/provider/story_provider.dart';
import 'screens/learn/learn_screen.dart';
import 'screens/report/report_screen.dart';
import 'screens/community/community_chat_screen.dart';
import 'screens/dummy_notepad/dummy_notepad_screen.dart';
// Temporarily remove screen imports and routes until files are created

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GBV Shield',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/learn': (context) => const LearnScreen(),
        '/report': (context) => const ReportScreen(),
        '/community': (context) => const CommunityChatScreen(),
        '/dummyNotepad': (context) => const QuickExitSettingsScreen(),
      },
      builder: (context, child) {
        return FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final prefs = snapshot.data!;
              final quickExitEnabled =
                  prefs.getBool('quickExitEnabled') ?? false;

              if (quickExitEnabled) {
                return MaterialApp(
                  title: 'Notepad',
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
                  ),
                  home: const DummyNotepadScreen(),
                  routes: {
                    '/home': (context) => const HomeScreen(),
                    '/login': (context) => const LoginScreen(),
                    '/signup': (context) => const SignupScreen(),
                    '/learn': (context) => const LearnScreen(),
                    '/report': (context) => const ReportScreen(),
                    '/community': (context) => const CommunityChatScreen(),
                    '/dummyNotepad': (context) =>
                        const QuickExitSettingsScreen(),
                  },
                );
              }
            }
            return child!;
          },
        );
      },
    );
  }
}
