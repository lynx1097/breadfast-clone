import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:breadfast/services/cart_service.dart';
import 'package:breadfast/models/product_model.dart';
import 'package:breadfast/widgets/product_details_sheet.dart';
import 'package:breadfast/widgets/app_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String priceString = product.currentPrice.toStringAsFixed(2);
    String integerPart = priceString.split('.')[0];
    String decimalPart = '.${priceString.split('.')[1]}';

    String? oldPriceString;
    if (product.isDiscounted && product.oldPrice != null) {
      oldPriceString = product.oldPrice!.toStringAsFixed(2);
    }

    final cartService = Provider.of<CartService>(context);
    final cartItem = cartService.items[product.id];
    final int currentQuantityInCart = cartItem?.quantity ?? 0;
    final bool isSoldOut = (product.inventoryCount ?? 0) <= 0;

    // Determine chip positions to avoid overlap
    List<Widget> chips = [];
    if (isSoldOut) {
      chips.add(_buildChip('Sold out', Colors.grey.shade100, Colors.grey.shade700));
    }
    if (product.isNew && !isSoldOut) { // Show NEW only if not sold out, to avoid too many chips
      chips.add(_buildChip('NEW', Colors.pink.shade50, Colors.pink.shade700));
    }
    if (product.showPointsMultiplier && !isSoldOut) {
      chips.add(_buildChip('2X Points', Colors.teal.shade50, Colors.teal.shade700));
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150, // Ensure width is set for GridView compatibility
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7.0)),
                    child: AppImage(url: product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 40.0), // Space for the button
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: integerPart,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Faro'),
                                ),
                                TextSpan(
                                  text: decimalPart,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Faro'),
                                ),
                              ],
                            ),
                          ),
                          if (product.isDiscounted && oldPriceString != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(
                                oldPriceString,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  decoration: TextDecoration.lineThrough,
                                  fontFamily: 'Faro',
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.productName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade700,
                          fontFamily: 'Faro',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Chips Display (Sold out, NEW, 2X Points)
            if (chips.isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: chips.map((chip) => Padding(padding: const EdgeInsets.only(bottom: 4.0), child: chip)).toList(),
                ),
              ),
            
            // Favorite Icon
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: product.isFavorite ? Colors.red : Colors.grey.shade400,
                ),
                onPressed: onFavoriteToggle,
              ),
            ),

            // Add to cart button / Quantity controls
            Positioned(
              bottom: 8,
              right: 8,
              child: isSoldOut
                  ? _buildNotifyMeButton() // Bell icon for sold out
                  : currentQuantityInCart == 0
                      ? _buildAddToCartButton(cartService) // Plus icon
                      : _buildQuantityControls(cartService, currentQuantityInCart), // Minus, Qty, Plus
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Faro'),
      ),
    );
  }

  Widget _buildAddToCartButton(CartService cartService) {
    return GestureDetector(
      onTap: () {
        cartService.addItem(product.id, product.name, product.imageUrl, product.currentPrice);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.purple,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildNotifyMeButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement Notify Me logic
        print('Notify Me tapped for ${product.name}');
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.pink.shade50, // Light pink/purple as in image
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.notifications_none_outlined, color: Colors.purple.shade600, size: 22),
      ),
    );
  }

  Widget _buildQuantityControls(CartService cartService, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.purple.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 2, offset: const Offset(0,1)) ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => cartService.removeSingleItem(product.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Icon(Icons.remove, color: Colors.purple, size: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Faro')),
          ),
          InkWell(
            onTap: () => cartService.addItem(product.id, product.name, product.imageUrl, product.currentPrice),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Icon(Icons.add, color: Colors.purple, size: 20),
            ),
          ),
        ],
      ),
    );
  }
} 