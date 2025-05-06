import 'package:flutter/material.dart';
// import 'egypt_auth_screen.dart'; // Old import
import 'phone_auth_screen.dart'; // Import the new PhoneAuthScreen

class SelectCountryScreen extends StatefulWidget {
  const SelectCountryScreen({super.key});

  @override
  State<SelectCountryScreen> createState() => _SelectCountryScreenState();
}

enum Country {
  egypt,
  saudiArabia,
}

class _SelectCountryScreenState extends State<SelectCountryScreen> {
  Country? _selectedCountry;

  Widget _buildCountryButton(String name, String flag, Country country) {
    bool isSelected = _selectedCountry == country;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCountry = country;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.purple.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 3,
              )
            ] : [],
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(name, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isContinueEnabled = _selectedCountry == Country.egypt;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBFB), // Light minty/off-white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 2),
              Image.asset(
                'assets/images/logo.png', 
                height: 70,
              ),
              const Spacer(flex: 3),
              const Text(
                'Select country',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildCountryButton('Egypt', '🇪🇬', Country.egypt),
              _buildCountryButton('Saudi Arabia', '🇸🇦', Country.saudiArabia),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isContinueEnabled ? Colors.purple : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontFamily: 'Faro', fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: isContinueEnabled ? 2 : 0,
                ),
                onPressed: isContinueEnabled
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
                        );
                      }
                    : null,
                child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const Spacer(flex: 1),
              Text(
                'You can change the country from the account settings at any time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
} 