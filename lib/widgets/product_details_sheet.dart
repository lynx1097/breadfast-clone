import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:breadfast/models/product_model.dart';
import 'package:breadfast/services/cart_service.dart';
// Import AppShell or a way to get the cart icon with badge if needed directly
// For simplicity, we might use a simple cart icon first and enhance later.

class ProductDetailsSheet extends StatefulWidget {
  final Product product;

  const ProductDetailsSheet({super.key, required this.product});

  @override
  State<ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<ProductDetailsSheet> {
  bool _isFavorite = false; // Local state for favorite

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
    // TODO: Potentially sync with a global favorite service if needed beyond local ProductCard state
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      widget.product.isFavorite = _isFavorite; 
      // TODO: Call a service to update favorite status in Firebase
      // For now, this updates the product object passed to the sheet
      // and will reflect on the card if the card's product object is the same instance
      // or if the parent screen rebuilds ProductCard with updated product.
    });
  }

  Widget _buildCartIconWithBadge(BuildContext context) {
    // This is a simplified version. For the exact badge like in AppShell,
    // you might need to pass CartService or make AppShell's badge builder more generic/accessible.
    final cartService = Provider.of<CartService>(context, listen: false);
    int itemCount = cartService.totalIndividualItems;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.shopping_cart_outlined, color: Colors.purple.shade600, size: 28),
        if (itemCount > 0)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  '$itemCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final cartItem = cartService.items[widget.product.id];
    final int currentQuantityInCart = cartItem?.quantity ?? 0;
    final bool isSoldOut = (widget.product.inventoryCount ?? 0) <= 0;

    String priceString = widget.product.currentPrice.toStringAsFixed(2);
    // String integerPartPrice = priceString.split('.')[0];
    // String decimalPartPrice = priceString.split('.')[1];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85, // Adjusted to 85%
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        child: Scaffold( // Using Scaffold for easy AppBar and BottomNavBAr like structure
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.purple.shade600, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // TODO: Add title if needed, or keep it clean
                  Consumer<CartService>( // Ensure badge updates
                    builder: (context, cart, child) {
                       return _buildCartIconWithBadge(context);
                    }
                  )
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Center(
                  child: SizedBox(
                    height: 200, // Adjust as needed
                    child: Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Price and Stock Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EGP ${priceString}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Faro'),
                    ),
                    Text(
                      isSoldOut ? 'Sold out' : 'In stock',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Faro',
                        color: isSoldOut ? Colors.red.shade600 : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Product Name
                Text(
                  widget.product.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Faro'),
                ),
                const SizedBox(height: 6),

                // Manufacturer/Brand and Favorite Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.product.manufacturer ?? 'Breadfast', // Fallback to Breadfast
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontFamily: 'Faro'),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red.shade600 : Colors.grey.shade400,
                        size: 28,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 16),

                // "About this product" Section (Phase 2)
                const Text(
                  'About this product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Faro'),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.itemDescription ?? 'No description available.',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700, fontFamily: 'Faro', height: 1.4),
                ),
                const SizedBox(height: 24),

                // "Related Products" Section (Phase 2 - Conditional on stock)
                if (!isSoldOut) ...[
                  const Text(
                    'Related Products',
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Faro'),
                  ),
                  const SizedBox(height: 12),
                  // Placeholder for horizontal list of ProductCards
                  SizedBox(
                    height: 230, // Adjust based on ProductCard size
                    child: Center(
                      child: Text(
                        '(Related products will show here)',
                        style: TextStyle(color: Colors.grey.shade500, fontFamily: 'Faro'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]

              ],
            ),
          ),
          // Bottom Action Bar
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16), // Safe area for bottom
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 0, blurRadius: 10)
              ],
            ),
            child: isSoldOut
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: null, // Disabled
                    child: Text(
                      'Notify me',
                      style: TextStyle(fontSize: 16, fontFamily: 'Faro', fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                    ),
                  )
                : currentQuantityInCart == 0
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        onPressed: () {
                          cartService.addItem(widget.product.id, widget.product.name, widget.product.imageUrl, widget.product.currentPrice);
                        },
                        child: const Text(
                          'Add to cart',
                          style: TextStyle(fontSize: 16, fontFamily: 'Faro', fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      )
                    : Row( // Quantity controls and total
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildQuantityButton(
                                icon: Icons.remove,
                                onPressed: () => cartService.removeSingleItem(widget.product.id),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  currentQuantityInCart.toString(),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Faro'),
                                ),
                              ),
                              _buildQuantityButton(
                                icon: Icons.add,
                                onPressed: () => cartService.addItem(widget.product.id, widget.product.name, widget.product.imageUrl, widget.product.currentPrice),
                              ),
                            ],
                          ),
                          Text(
                            'EGP ${(widget.product.currentPrice * currentQuantityInCart).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Faro', color: Colors.black87),
                          )
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.purple.shade700, size: 22),
      ),
    );
  }
}

// Helper function to show the sheet (can be called from ProductCard's onTap)
void showProductDetailsSheet(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Important for custom height and scrolling
    backgroundColor: Colors.transparent, // Make sheet's background transparent
    builder: (BuildContext context) {
      return ProductDetailsSheet(product: product);
    },
  );
} 