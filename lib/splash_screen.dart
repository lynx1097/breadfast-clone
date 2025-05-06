import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:breadfast/app_shell.dart'; // Will be conditional later
import 'package:breadfast/screens/select_country_screen.dart'; // Import SelectCountryScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () {
        // TODO: Implement logic to check if user is logged in
        // For now, always navigate to SelectCountryScreen
        bool isLoggedIn = false; // Placeholder

        if (isLoggedIn) {
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (_) => const AppShell()),
          // );
          // TEMP: Fallback to SelectCountryScreen for now even if logic says AppShell
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SelectCountryScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SelectCountryScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1), // Light mint/cyan background
      body: Center(
        child: Image.asset('assets/images/breadfast-no-text.jpg'),
      ),
    );
  }
} 