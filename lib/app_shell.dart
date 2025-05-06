import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/pay_screen.dart';
import 'screens/more_screen.dart';
import 'package:breadfast/services/cart_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    const SearchScreen(),
    const CartScreen(),
    const PayScreen(),
    const MoreScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) { // Index 2 is Cart
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
      // Do not change _selectedIndex when navigating to cart as a separate screen
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildCartIconWithBadge(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, child) {
        int itemCount = cart.totalIndividualItems;
        return Stack(
          clipBehavior: Clip.none, // Allow badge to go outside icon bounds
          children: [
            child!, // The original icon
            if (itemCount > 0)
              Positioned(
                right: -4, // Adjust position for badge
                top: -4,  // Adjust position for badge
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red, // Badge color
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5)
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: const Icon(Icons.shopping_cart_outlined), // Base icon
    );
  }
 
  Widget _buildActiveCartIconWithBadge(BuildContext context) {
     return Consumer<CartService>(
      builder: (context, cart, child) {
        int itemCount = cart.totalIndividualItems;
        return Stack(
          clipBehavior: Clip.none, 
          children: [
            child!, // The original icon
            if (itemCount > 0)
              Positioned(
                right: -4, 
                top: -4,  
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red, 
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5)
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: const Icon(Icons.shopping_cart), // Base active icon
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if AppBar should be shown based on the selected index
    PreferredSizeWidget? appBar;
    if (_selectedIndex == 0) { // Only show AppBar for HomeScreen (index 0)
      // We will reconstruct the HomeScreen's specific AppBar here or pass a flag
      // For now, let's use the AppBar from HomeScreen itself by ensuring HomeScreen returns a Scaffold with an AppBar.
      // This will be handled by _widgetOptions providing the full screen including its own AppBar.
    } else {
      appBar = null; // No AppBar for other screens
    }

    return Scaffold(
      // The appBar property is now managed by the individual screens in _widgetOptions.
      // If a screen (like HomeScreen) defines an AppBar, it will be used.
      // If other screens don't define an AppBar (or return a Scaffold without one), no AppBar will be shown.
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1.0), // Added top stroke
          ),
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: _buildCartIconWithBadge(context),
              activeIcon: _buildActiveCartIconWithBadge(context),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.payment_outlined),
              activeIcon: Icon(Icons.payment),
              label: 'Pay',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined),
              activeIcon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.purple, // Active icon/label color
          unselectedItemColor: Colors.grey,   // Inactive icon/label color
          onTap: _onItemTapped,
          backgroundColor: Colors.white,      // Background color of the bar
          type: BottomNavigationBarType.fixed, // Ensures all items are visible and labels are shown
          elevation: 0, // Elevation moved to Container or set to 0 if border is enough
          showUnselectedLabels: true, // Make sure labels are always shown
          iconSize: 28.0, // Increased icon size
        ),
      ),
    );
  }
} 