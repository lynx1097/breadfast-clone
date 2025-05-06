import 'package:flutter/material.dart';
import 'package:breadfast/models/user_model.dart'; // To potentially receive user data

class PasswordScreen extends StatefulWidget {
  // final String phoneNumber; // Or pass the whole user map/model
  final Map<String, dynamic> existingUserData; // Contains UID, phone, name etc.

  const PasswordScreen({super.key, required this.existingUserData});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _trySubmit() {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (isValid == true) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });
      // TODO: Implement actual password verification against stored (hashed) password
      // This will involve fetching the stored hash from widget.existingUserData or DB again
      // and comparing it with a hash of _passwordController.text.
      print('Simulating Login...');
      print('Phone: ${widget.existingUserData["phoneNumber"]}');
      print('UID: ${widget.existingUserData["uid"]}');
      print('Entered Password: ${_passwordController.text}');
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        // TODO: Navigate to AppShell or appropriate screen after successful login
        // For now, pop all the way back and assume main.dart will handle routing to AppShell
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String displayPhoneNumber = widget.existingUserData['phoneNumber'] ?? 'N/A';
    if (displayPhoneNumber.startsWith('+20')) {
      displayPhoneNumber = displayPhoneNumber.substring(3); // Show local part
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Password'),
         leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple.shade400),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Welcome back, ${widget.existingUserData['firstName'] ?? 'User'}!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your password for +20$displayPhoneNumber',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                 if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                       style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontFamily: 'Faro', fontWeight: FontWeight.w600),
                      ),
                      onPressed: _trySubmit,
                      child: const Text('Log In', style: TextStyle(color: Colors.white)),
                    ),
                const Spacer(), // Pushes to bottom
                 // Optional: Forgot password link
                TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password flow
                    print('Forgot password tapped');
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.purple, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
} 