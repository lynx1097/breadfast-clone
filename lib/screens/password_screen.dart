import 'package:flutter/material.dart';
import 'package:breadfast/app_shell.dart'; // For navigation
// import 'package:breadfast/models/user_model.dart'; // Already passed as Map
// import 'package:breadfast/services/database_service.dart'; // For future password verification logic
// import 'package:breadfast/services/password_service.dart'; // Removed
import 'package:breadfast/services/auth_service.dart'; // Import AuthService

class PasswordScreen extends StatefulWidget {
  final Map<String, dynamic> existingUserData;

  const PasswordScreen({super.key, required this.existingUserData});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  String? _passwordErrorText;
  bool _isButtonEnabled = false;

  // final PasswordService _passwordService = PasswordService(); // Removed
  final AuthService _authService = AuthService(); // Instantiate

  // final DatabaseService _dbService = DatabaseService(); // For future use

 @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkButtonState);
    _passwordFocusNode.addListener(() => setState(() {})); // For focus-based styling
  }

  void _checkButtonState() {
    bool shouldBeEnabled = _passwordController.text.isNotEmpty;
    if (_isButtonEnabled != shouldBeEnabled) {
      setState(() {
        _isButtonEnabled = shouldBeEnabled;
      });
    }
  }

  Future<void> _tryLogin() async {
    setState(() {
      _passwordErrorText = null; // Clear previous error
    });

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      String enteredPassword = _passwordController.text;
      // String? storedHashedPassword = widget.existingUserData['hashedPassword'] as String?; // Changed
      String? storedPassword = widget.existingUserData['password'] as String?;
      String userId = widget.existingUserData['uid'] as String;

      bool loginSuccess = false;
      // if (storedHashedPassword != null && storedHashedPassword.isNotEmpty) { // Changed
      //   loginSuccess = await _passwordService.verifyPassword(
      //     password: enteredPassword,
      //     hashedPassword: storedHashedPassword,
      //   );
      // } else {
      //   // Handle case where there's no stored hash (e.g., old user or data issue)
      //   _passwordErrorText = 'Login not possible. Please contact support.'; 
      // }

      if (storedPassword != null && storedPassword.isNotEmpty) {
        loginSuccess = enteredPassword == storedPassword;
      } else {
        // If password is not in DB for some reason, or it's empty
        _passwordErrorText = 'Login failed. User data incomplete.';
      }


      // Simulate network delay for UI feel, remove for production
      // await Future.delayed(const Duration(seconds: 1)); 

      if (!mounted) return;

      if (loginSuccess) {
        await _authService.loginUserSession(userId); // Create session
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AppShell()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          if (_passwordErrorText == null) { // Only set if not already set by specific conditions above
             _passwordErrorText = 'Invalid password';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, FocusNode focusNode, {String? errorText}) {
    bool hasFocus = focusNode.hasFocus;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: hasFocus ? Colors.purple : Colors.grey.shade600,
        fontSize: 14, 
      ),
      floatingLabelStyle: const TextStyle(color: Colors.purple, fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), // Adjusted padding
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.purple, width: 1.5),
      ),
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userFirstName = widget.existingUserData['firstName'] ?? 'User';
    String displayPhoneNumber = widget.existingUserData['phoneNumber'] as String? ?? 'N/A';
    // Remove country code if present for display
    if (displayPhoneNumber.startsWith('+20')) {
      displayPhoneNumber = displayPhoneNumber.substring(3);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple.shade400, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.purple.shade400),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.normal),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              Text(
                'Welcome back, $userFirstName!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your password for +20$displayPhoneNumber',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: _inputDecoration('Password', _passwordFocusNode, errorText: _passwordErrorText),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _isButtonEnabled ? _tryLogin() : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                ),
              ),
              // Removed Spacer to bring button closer to field
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isButtonEnabled ? Colors.purple : Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontFamily: 'Faro', fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          onPressed: (_isButtonEnabled && !_isLoading) ? _tryLogin : null,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text('Confirm', style: TextStyle(color: _isButtonEnabled ? Colors.white : Colors.grey.shade700)),
        ),
      ),
    );
  }
} 