import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/incident_service.dart';
import 'services/emergency_contact_service.dart';
import 'providers/incident_provider.dart';
import 'providers/emergency_contact_provider.dart';
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
import 'screens/profile/my_reports_screen.dart';
import 'providers/tip_provider.dart';
import 'providers/learn_provider.dart';
import 'providers/emergency_provider.dart';
// Temporarily remove screen imports and routes until files are created

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final apiService = ApiService(prefs);
  final bool quickExitEnabled = prefs.getBool('quickExitEnabled') ?? false;

  runApp(
    MyApp(
      initialRoute: quickExitEnabled ? '/dummy-notepad' : '/splash',
      apiService: apiService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final ApiService apiService;

  const MyApp({Key? key, required this.initialRoute, required this.apiService})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(), lazy: false),
        ChangeNotifierProxyProvider<AuthProvider, LearnProvider>(
          create: (context) =>
              LearnProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, _) => LearnProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, IncidentProvider>(
          create: (context) => IncidentProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, _) => IncidentProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EmergencyProvider>(
          create: (context) => EmergencyProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, _) => EmergencyProvider(auth),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              EmergencyContactProvider(EmergencyContactService(apiService)),
        ),
        ChangeNotifierProvider(create: (_) => StoryProvider(), lazy: false),
        ChangeNotifierProxyProvider<AuthProvider, TipProvider>(
          create: (context) => TipProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => TipProvider(auth),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'GBV Shield',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: const Color(0xFF7C3AED),
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: initialRoute,
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/dummy-notepad': (context) => const DummyNotepadScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/learn': (context) => const LearnScreen(),
          '/report': (context) => const ReportScreen(),
          '/community': (context) => const CommunityChatScreen(),
          '/quick-exit-settings': (context) => const QuickExitSettingsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/my-reports': (context) => const MyReportsScreen(),
        },
      ),
    );
  }
}
