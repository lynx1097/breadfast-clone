import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:breadfast/services/database_service.dart'; // Import DatabaseService
import 'sign_up_screen.dart'; // Import SignUpScreen
import 'password_screen.dart'; // Import PasswordScreen

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final DatabaseService _dbService = DatabaseService(); // Instantiate DatabaseService
  bool _isPhoneNumberValid = false;
  String _phoneNumber = '';
  bool _isLoading = false; // For loading state of the button

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
    _phoneFocusNode.addListener(() {
      setState(() {}); // To rebuild and update border color on focus change
    });
  }

  void _validatePhoneNumber() {
    String currentText = _phoneController.text;
    setState(() {
      _phoneNumber = currentText;
      if (currentText.startsWith('1') && currentText.length == 10) {
        _isPhoneNumberValid = true;
      } else {
        _isPhoneNumberValid = false;
      }
    });
  }

  Future<void> _onContinuePressed() async {
    if (!_isPhoneNumberValid) return;

    setState(() {
      _isLoading = true;
    });

    final rawPhoneNumber = _phoneController.text;
    final existingUserData = await _dbService.getUserByPhoneNumber(rawPhoneNumber);

    if (!mounted) return; // Check if the widget is still in the tree

    setState(() {
      _isLoading = false;
    });

    if (existingUserData != null) {
      // User exists, navigate to PasswordScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PasswordScreen(existingUserData: existingUserData)),
      );
    } else {
      // User does not exist, navigate to SignUpScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpScreen(phoneNumber: rawPhoneNumber)),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasFocus = _phoneFocusNode.hasFocus;

    return Scaffold(
      backgroundColor: Colors.white, // Assuming a white background like the image
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple.shade400),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Log in or sign up',
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll send you an SMS for verification.',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              // Phone Number Input Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0), // Minimal padding for inner content
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (hasFocus || _isPhoneNumberValid) && _phoneNumber.isNotEmpty ? Colors.purple : Colors.grey.shade300,
                    width: (hasFocus || _isPhoneNumberValid) && _phoneNumber.isNotEmpty ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    // Country Code Picker (Static for now)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0), // Padding for this section
                      decoration: BoxDecoration(
                         color: Colors.grey.shade100, // Light background for this part
                         borderRadius: const BorderRadius.only(
                           topLeft: Radius.circular(6.0),
                           bottomLeft: Radius.circular(6.0),
                         )
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🇪🇬', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Text(
                            '+20',
                            style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.black54),
                        ],
                      ),
                    ),
                    // VerticalDivider(thickness: 1, color: Colors.grey.shade300), // Optional divider
                    // Phone Number TextField
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0), // Padding before text field
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          maxLength: 10, // Max length for phone number (after '1')
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: '', // Hide the counter
                            labelText: 'Mobile number',
                            labelStyle: TextStyle(
                              color: (hasFocus || _phoneNumber.isNotEmpty) ? Colors.green.shade700 : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto, // Or .always
                            suffixIcon: _isPhoneNumberValid
                                ? Icon(Icons.check_circle, color: Colors.green.shade700, size: 20)
                                : null,
                          ),
                          style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(), // Pushes content to bottom
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  children: <TextSpan>[
                    const TextSpan(text: 'By proceeding, you agree to our '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w500),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Navigate to Terms and Conditions
                          print('Terms and Conditions tapped');
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w500),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Navigate to Privacy Policy
                          print('Privacy Policy tapped');
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPhoneNumberValid ? Colors.purple : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontFamily: 'Faro', fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: _isPhoneNumberValid ? 2 : 0,
                ),
                onPressed: (_isPhoneNumberValid && !_isLoading) ? _onContinuePressed : null,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3.0))
                    : Text(
                        'Continue',
                        style: TextStyle(color: _isPhoneNumberValid ? Colors.white : Colors.grey.shade700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 