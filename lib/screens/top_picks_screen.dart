import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:breadfast/services/cart_service.dart'; // Import CartService
import 'package:breadfast/widgets/product_card.dart'; // Import new ProductCard
import 'package:breadfast/widgets/product_details_sheet.dart'; // Import the sheet
import 'cart_screen.dart'; // Import CartScreen for navigation
import 'package:breadfast/models/product_model.dart';
import 'package:breadfast/services/database_service.dart';

class TopPicksScreen extends StatefulWidget { // Changed to StatefulWidget
  TopPicksScreen({super.key});

  @override
  _TopPicksScreenState createState() => _TopPicksScreenState();
}

class _TopPicksScreenState extends State<TopPicksScreen> { // State class
  final DatabaseService _dbService = DatabaseService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _dbService.getProducts(limit: 20); // Fetch 20 products or all active
  }

  void _toggleFavoriteStatus(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
      // Consider if a more direct UI update is needed or if FutureBuilder will re-evaluate.
      // For now, this updates the model. If products list is held in state, update it there.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top picks for you',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0, 
        iconTheme: const IconThemeData(color: Colors.black87), // For back arrow
        actions: [
          Consumer<CartService>(
            builder: (context, cart, child) {
              int itemCount = cart.totalIndividualItems;
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.purple), // Icon color to match theme
                    if (itemCount > 0)
                      Positioned(
                        right: -5, // Adjust position for badge
                        top: -5,  // Adjust position for badge
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
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8), // Some padding for the action icon
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0), 
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products found'));
            } else {
              final products = snapshot.data!;
              return GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 150 / 260, 
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onFavoriteToggle: () => _toggleFavoriteStatus(product),
                    onTap: () => showProductDetailsSheet(context, product),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
} 