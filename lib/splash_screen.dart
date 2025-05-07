import 'dart:async';
import 'package:flutter/material.dart';
import 'package:breadfast/app_shell.dart'; 
import 'package:breadfast/screens/select_country_screen.dart';
import 'package:breadfast/services/auth_service.dart'; // Import AuthService

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService(); // Instantiate

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3)); // Keep splash visible
    
    if (!mounted) return;

    bool isLoggedIn = await _authService.isLoggedIn();

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SelectCountryScreen()),
      );
    }
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