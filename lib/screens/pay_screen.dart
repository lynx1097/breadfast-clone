import 'package:flutter/material.dart';
import 'package:breadfast/services/auth_service.dart'; // If needed for user data
import 'package:breadfast/services/database_service.dart'; // If needed for user data
import 'package:breadfast/models/user_model.dart'; // If needed for user data

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  // final AuthService _authService = AuthService();
  // final DatabaseService _dbService = DatabaseService();
  // UserModel? _currentUser;
  // double _walletBalance = 2.01; // Placeholder, fetch from user model later
  bool _isLoading = false; // If we need to fetch data

  @override
  void initState() {
    super.initState();
    // _fetchUserData(); // Implement if user-specific data is needed for wallet
  }

  // Future<void> _fetchUserData() async {
  //   setState(() { _isLoading = true; });
  //   // Fetch user data and wallet balance
  //   // String? userId = await _authService.getCurrentUserId();
  //   // if (userId != null) {
  //   //   Map<String, dynamic>? userDataMap = await _dbService.getUserByUid(userId);
  //   //   if (userDataMap != null) {
  //   //     _currentUser = UserModel.fromMap(userDataMap, userId);
  //   //     _walletBalance = _currentUser?.walletBalance ?? 0.0; // Assuming walletBalance field
  //   //   }
  //   // }
  //   setState(() { _isLoading = false; });
  // }

  Widget _buildBalanceActionButton(BuildContext context, IconData icon, String label, Color backgroundColor, Color iconColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ]
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Faro',
            color: Colors.purple.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder balance for now
    double walletBalance = 2.01;
    String balanceIntegerPart = walletBalance.floor().toString();
    String balanceDecimalPart = (walletBalance - walletBalance.floor()).toStringAsFixed(2).substring(2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const SizedBox.shrink(), // No title as per instruction to ignore logo
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.purple.shade400, size: 26),
            onPressed: () {
              // TODO: Implement chat navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat tapped (Not implemented yet)')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet Balance',
                    style: TextStyle(
                      fontFamily: 'Faro',
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0), // Align EGP with top of number
                        child: Text(
                          'EGP',
                          style: TextStyle(
                            fontFamily: 'Faro',
                            fontSize: 20, 
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        balanceIntegerPart,
                        style: const TextStyle(
                          fontFamily: 'Faro',
                          fontSize: 38, // Larger size for integer part
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 1), // Align decimal with top of number
                        child: Text(
                          '.${balanceDecimalPart}',
                          style: TextStyle(
                            fontFamily: 'Faro',
                            fontSize: 20, // Smaller size for decimal part
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildBalanceActionButton(
                        context,
                        Icons.add,
                        'Add to\nBalance',
                        Colors.purple.shade700,
                        Colors.white,
                      ),
                      const SizedBox(width: 16),
                      _buildBalanceActionButton(
                        context,
                        Icons.credit_card_outlined,
                        'Saved\nCards',
                        Colors.purple.shade50,
                        Colors.purple.shade700,
                      ),
                    ],
                  ),
                  const Spacer(), // Pushes content below to the center
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TODO: Replace with actual rocket image from assets
                        Icon(
                          Icons.rocket_launch_outlined, 
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Exciting things are on the way!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Faro',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'In the meantime, our bill payment services are\ntemporarily unavailable.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Faro',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(), // Pushes content above to the center
                ],
              ),
            ),
    );
  }
} 