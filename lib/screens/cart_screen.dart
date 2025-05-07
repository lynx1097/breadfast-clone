import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:breadfast/services/cart_service.dart';
import 'package:breadfast/app_shell.dart'; // To navigate back to home/AppShell
import 'package:breadfast/widgets/product_card.dart'; // For People also buy section later
import 'package:breadfast/widgets/product_details_sheet.dart'; // Import the sheet
import 'package:breadfast/models/product_model.dart'; // Import Product model

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0, 
        iconTheme: IconThemeData(color: Colors.purple.shade400), // Purple back arrow
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple.shade400),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (cartService.itemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () {
                  // Show confirmation dialog before clearing cart
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear Cart?'),
                      content: const Text('Are you sure you want to remove all items from your cart?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Clear', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            cartService.clearCart();
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Clear all',
                  style: TextStyle(color: Colors.purple.shade400, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: cartService.itemCount == 0
          ? _buildEmptyCart(context)
          : _buildCartWithItemsLayout(context, cartService), // Changed method name for clarity
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'No products added yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start shopping and add items.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Theme color
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )
              ),
              onPressed: () {
                // Navigate back to home, assuming AppShell is the root after splash
                // If AppShell is not always the direct parent, this might need adjustment
                // For now, pop until we reach AppShell or root, or push a new AppShell.
                // A simple pop might be enough if CartScreen is pushed from AppShell.
                Navigator.of(context).popUntil((route) => route.isFirst); 
                // Or if you want to ensure it goes to AppShell's first tab (Home):
                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(builder: (context) => const AppShell()), 
                //   (Route<dynamic> route) => false,
                // );
              },
              child: const Text('Explore now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartWithItemsLayout(BuildContext context, CartService cartService) {
    final cartItems = cartService.items.values.toList();

    final List<Map<String, dynamic>> peopleAlsoBuyData = List.generate(
      5,
      (index) => {
        'id': 'pab$index',
        'name': 'Also Buy Item ${index + 1}',
        'imageUrl': 'https://via.placeholder.com/150/D2B48C/FFFFFF?text=Product+${index+1}', // Placeholder image URL
        'price': (index + 1) * 30.25,
        'oldPrice': null,
        'isDiscounted': false,
        'showPointsMultiplier': (index % 2 != 0),
        'isFavorite': false,
        'inventoryCount': 10, // Assuming in stock for placeholder
        'itemDescription': 'This is a placeholder description for also buy item ${index + 1}.',
        'manufacturer': 'Breadfast',
      }
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Handled by SingleChildScrollView
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartListItem(context, item, cartService);
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                ),
                const SizedBox(height: 24),
                // --- People also buy Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'People also buy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(
                  height: 260, // Same height as in HomeScreen for ProductCard list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: peopleAlsoBuyData.length,
                    itemBuilder: (context, index) {
                      final pItem = peopleAlsoBuyData[index];
                      final product = Product(
                        id: pItem['id'] as String,
                        name: pItem['name'] as String,
                        imageUrl: pItem['imageUrl'] as String,
                        price: pItem['price'] as double,
                        oldPrice: pItem['oldPrice'] as double?,
                        isDiscounted: pItem['isDiscounted'] as bool,
                        showPointsMultiplier: pItem['showPointsMultiplier'] as bool,
                        isFavorite: pItem['isFavorite'] as bool,
                        inventoryCount: pItem['inventoryCount'] as int?,
                        itemDescription: pItem['itemDescription'] as String?,
                        manufacturer: pItem['manufacturer'] as String?,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ProductCard(
                          product: product,
                          onFavoriteToggle: () {
                            print('Fav toggle for PAB: ${product.name}');
                            // TODO: Make CartScreen stateful to manage this state
                          },
                          onTap: () => showProductDetailsSheet(context, product), // Added onTap
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Space before checkout bar if it were part of scroll
              ],
            ),
          ),
        ),
        // Checkout Bar (will be built as a separate component at the bottom)
        _buildCheckoutBar(context, cartService),
      ],
    );
  }

  Widget _buildCartListItem(BuildContext context, CartItem item, CartService cartService) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Temporarily store item details for undo
        final removedItem = CartItem(id: item.id, name: item.name, imageUrl: item.imageUrl, price: item.price, quantity: item.quantity);
        cartService.removeItemCompletely(item.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${removedItem.name} removed'),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.amber, // Or your theme's accent color for actions
              onPressed: () {
                // Re-add the item with its previous quantity
                // This might need a more specific method in CartService if complex logic is needed for re-adding
                for (int i = 0; i < removedItem.quantity; i++) {
                    cartService.addItem(removedItem.id, removedItem.name, removedItem.imageUrl, removedItem.price);
                }
              },
            ),
            duration: const Duration(seconds: 3), // Give user some time to react
          ),
        );
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete_outline, color: Colors.white),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              // child: Image.network(item.imageUrl, fit: BoxFit.cover), // Later
              child: Center(child: Icon(Icons.photo, color: Colors.grey.shade400)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EGP ${item.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Quantity Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      // If quantity is 1, this acts like delete, otherwise decrement
                      cartService.removeSingleItem(item.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                      child: Icon(
                        item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                        color: Colors.purple.shade400,
                        size: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0), // Increased padding for quantity text
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      cartService.addItem(item.id, item.name, item.imageUrl, item.price);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                      child: Icon(Icons.add, color: Colors.purple.shade400, size: 20),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartService cartService) {
    if (cartService.itemCount == 0) return const SizedBox.shrink();

    // Prepare price strings for rich text
    String grandTotalStr = cartService.grandTotalPrice.toStringAsFixed(2);
    String totalIntegerPart = grandTotalStr.split('.')[0];
    String totalDecimalPart = '.${grandTotalStr.split('.')[1]}';

    return GestureDetector(
      onTap: () {
        print('Checkout tapped. Total: ${cartService.grandTotalPrice}');
        // TODO: Implement checkout navigation / logic
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.purple, 
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            // Left side: "Go to checkout" text
            const Text(
              'Go to checkout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white), // Regular weight
            ),
            // Right side: Price and fees, stacked vertically and aligned right
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'EGP ', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white), // EGP normal, smaller
                      ),
                      TextSpan(
                        text: totalIntegerPart,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Larger bold integer
                      ),
                      TextSpan(
                        text: totalDecimalPart,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), // Smaller bold decimal
                      ),
                    ],
                  ),
                ),
                if (cartService.itemCount > 0) 
                  Text(
                    '+${CartService.deliveryFee.toStringAsFixed(2)} delivery & service fees',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.8)), // Regular weight
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 