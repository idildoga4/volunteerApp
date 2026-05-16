import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'package:volunteer/screens/login_screen.dart';
import 'package:volunteer/screens/main_nav_screen.dart';

import 'widgets/theme.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const VolunteerApp());
}

class VolunteerApp extends StatefulWidget {
  const VolunteerApp({super.key});

  static _VolunteerAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_VolunteerAppState>();
  }

  @override
  State<VolunteerApp> createState() => _VolunteerAppState();
}

class _VolunteerAppState extends State<VolunteerApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void toggleTheme(bool value) async {
    setState(() {
      isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volunteer App',

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),

        useMaterial3: true,
      ),

      darkTheme: AppTheme.darkTheme,

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavScreen(),
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
