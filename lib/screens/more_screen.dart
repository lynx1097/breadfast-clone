import 'package:flutter/material.dart';
import 'package:breadfast/services/auth_service.dart';
import 'package:breadfast/services/database_service.dart';
import 'package:breadfast/models/user_model.dart';
import 'package:breadfast/screens/select_country_screen.dart'; // For logout navigation

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  UserModel? _currentUser;
  bool _isLoading = true;

  // Placeholder values, actual values will be from user data or settings
  String _language = 'English';
  String _country = 'Egypt';
  String _rewardsPoints = '823 Points'; // Example

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? userId = await _authService.getCurrentUserId();
      if (userId != null) {
        Map<String, dynamic>? userDataMap = await _dbService.getUserByUid(userId);
        if (userDataMap != null) {
          _currentUser = UserModel.fromMap(userDataMap, userId);
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _logout() async {
    await _authService.logoutUserSession();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SelectCountryScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
    Color? trailingTextColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 26),
      title: Text(
        title,
        style: const TextStyle(
            fontFamily: 'Faro', fontSize: 16, color: Colors.black87),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                fontFamily: 'Faro',
                fontSize: 15,
                color: trailingTextColor ?? Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 28),
        ],
      ),
      onTap: onTap, // If onTap is null, nothing happens. For specific actions like logout, it's provided.
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayName = _isLoading 
        ? 'Loading...' 
        : (_currentUser != null ? '${_currentUser!.firstName} ${_currentUser!.lastName}' : 'Guest User');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0, // No shadow for a cleaner look
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
            child: Text(
              displayName,
              style: const TextStyle(
                fontFamily: 'Faro',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ),
          automaticallyImplyLeading: false, // No back button if it's a main tab
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    children: <Widget>[
                      _buildListTile(icon: Icons.history_outlined, title: 'Activity History'),
                      _buildListTile(icon: Icons.favorite_border_outlined, title: 'Favorites'),
                      _buildListTile(
                        icon: Icons.card_giftcard_outlined, // Placeholder for trophy
                        title: 'Breadfast Rewards',
                        trailingText: _rewardsPoints,
                        trailingTextColor: Colors.purple,
                      ),
                      _buildListTile(icon: Icons.wallet_giftcard_outlined, title: 'Free Credit'), // Placeholder for gift box
                      const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
                      _buildListTile(icon: Icons.settings_outlined, title: 'Account Settings'),
                      _buildListTile(icon: Icons.help_outline_outlined, title: 'Help'),
                      _buildListTile(
                        icon: Icons.translate_outlined,
                        title: 'Language',
                        trailingText: _language,
                        trailingTextColor: Colors.purple,
                      ),
                      _buildListTile(
                        icon: Icons.language_outlined,
                        title: 'Country',
                        trailingText: _country,
                        trailingTextColor: Colors.purple,
                      ),
                      _buildListTile(icon: Icons.chat_bubble_outline_outlined, title: 'Talk to us'),
                      const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
                      _buildListTile(
                        icon: Icons.logout_outlined,
                        title: 'Log out',
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 