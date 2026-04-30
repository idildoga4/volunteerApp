import 'package:flutter/material.dart';
import 'package:volunteer/screens/login_screen.dart';
import 'package:volunteer/screens/main_nav_screen.dart';

import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const VolunteerApp());
}

class VolunteerApp extends StatelessWidget {
  const VolunteerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volunteer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/login': (context) => const LoginScreen(),
         '/home': (context) => const MainNavScreen(),
         
      },
      debugShowCheckedModeBanner: false,
    );

  }  } 