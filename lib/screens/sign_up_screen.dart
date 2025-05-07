import 'package:flutter/material.dart';
import 'package:breadfast/services/database_service.dart'; // For future use
import 'package:breadfast/app_shell.dart'; // For navigation after signup
import 'package:uuid/uuid.dart'; // For generating UID
// import 'package:breadfast/services/password_service.dart'; // Removed
import 'package:breadfast/services/auth_service.dart'; // Import AuthService

class SignUpScreen extends StatefulWidget {
  final String phoneNumber; // Phone number passed from PhoneAuthScreen

  const SignUpScreen({super.key, required this.phoneNumber});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isFormValid = false;

  final DatabaseService _dbService = DatabaseService();
//   final PasswordService _passwordService = PasswordService(); // Removed
  final AuthService _authService = AuthService(); // Instantiate
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    // Add listeners to check form validity on change
    _firstNameController.addListener(_checkFormValidity);
    _lastNameController.addListener(_checkFormValidity);
    _passwordController.addListener(_checkFormValidity);
    _confirmPasswordController.addListener(_checkFormValidity);
    // Add focus listeners to rebuild UI for border/label color changes
    _firstNameFocusNode.addListener(() => setState(() {}));
    _lastNameFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));

    // Set initial focus to first name
    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_firstNameFocusNode);
    });
  }

  void _checkFormValidity() {
    // Basic check, validator handles detailed messages
    bool isValid = _firstNameController.text.isNotEmpty &&
                   _lastNameController.text.isNotEmpty &&
                   _passwordController.text.length >= 6 &&
                   _confirmPasswordController.text == _passwordController.text;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _trySubmit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      String plainPassword = _passwordController.text;
      // String hashedPassword = await _passwordService.hashPassword(plainPassword); // Removed hashing

      String newUserId = _uuid.v4(); // Generate a unique ID for the new user

      Map<String, dynamic> userData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': '+20${widget.phoneNumber}', // Store with country code
        'email': '', // Email is optional, not collected here
        'password': plainPassword, // Store plaintext password (MOCK APP ONLY)
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'defaultAddressId': null,
      };

      try {
        await _dbService.createUser(newUserId, userData);
        await _authService.loginUserSession(newUserId); // Create session
        
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AppShell()), 
          (Route<dynamic> route) => false
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${error.toString()}')),
        );
      } finally {
         if (mounted) {
            setState(() {
              _isLoading = false;
            });
         }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, FocusNode focusNode, {bool isOptional = false}) {
    bool hasFocus = focusNode.hasFocus;
    String fullLabel = isOptional ? '$label (Optional)' : label;
    return InputDecoration(
      labelText: fullLabel,
      labelStyle: TextStyle(
        color: hasFocus ? Colors.purple : Colors.grey.shade600,
        fontSize: 13, // Smaller label
      ),
      floatingLabelStyle: TextStyle(color: Colors.purple, fontSize: 15), // Style when focused and floating
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Compact padding
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.purple, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple.shade400, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            onChanged: _checkFormValidity, // Check validity on any form field change
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Let\'s finish up your account',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add your basic information to get started with Breadfast!',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          focusNode: _firstNameFocusNode,
                          decoration: _inputDecoration('First name', _firstNameFocusNode),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter first name';
                            }
                            return null;
                          },
                           onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocusNode),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          focusNode: _lastNameFocusNode,
                          decoration: _inputDecoration('Last name', _lastNameFocusNode),
                          textInputAction: TextInputAction.next,
                           validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter last name';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    decoration: _inputDecoration('Password', _passwordFocusNode),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a password';
                      }
                      if (value.length < 6) {
                        return 'Min. 6 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    decoration: _inputDecoration('Confirm password', _confirmPasswordFocusNode),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords don\'t match';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _isFormValid ? _trySubmit() : null,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid ? Colors.purple : Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontFamily: 'Faro', fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            elevation: _isFormValid ? 2 : 0,
          ),
          onPressed: (_isFormValid && !_isLoading) ? _trySubmit : null,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text('Create account', style: TextStyle(color: _isFormValid ? Colors.white : Colors.grey.shade700)),
        ),
      ),
    );
  }
} 