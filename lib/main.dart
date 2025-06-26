import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/provider/auth_provider.dart';
import 'screens/home/provider/story_provider.dart';
import 'screens/learn/learn_screen.dart';
import 'screens/report/report_screen.dart';
import 'screens/community/community_chat_screen.dart';
import 'screens/dummy_notepad/dummy_notepad_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'providers/tip_provider.dart';
// Temporarily remove screen imports and routes until files are created

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => StoryProvider(),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<AuthProvider, TipProvider>(
          create: (context) => TipProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => TipProvider(auth),
          lazy: false,
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'GBV Shield',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              primaryColor: const Color(0xFF7C3AED),
              scaffoldBackgroundColor: Colors.white,
            ),
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/splash': (context) => const SplashScreen(),
              '/home': (context) => const HomeScreen(),
              '/learn': (context) => const LearnScreen(),
              '/report': (context) => const ReportScreen(),
              '/community': (context) => const CommunityChatScreen(),
              '/dummyNotepad': (context) => const QuickExitSettingsScreen(),
              '/profile': (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
