import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:breadfast/services/cart_service.dart';
import 'package:breadfast/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.product,
    required this.onFavoriteToggle,
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

    return Container(
      width: 150,
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
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 40.0),
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
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              TextSpan(
                                text: decimalPart,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (product.showPointsMultiplier)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50, 
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '2X Points',
                  style: TextStyle(fontSize: 10, color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            ),

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

          Positioned(
            bottom: 8, 
            right: 8,
            child: currentQuantityInCart == 0
                ? GestureDetector(
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
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white, // Background for the controls
                      border: Border.all(color: Colors.purple.shade200, width: 1.5),
                      borderRadius: BorderRadius.circular(20.0), // Rounded ends
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1, 
                            blurRadius: 2,
                            offset: const Offset(0,1),
                        )
                      ]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            cartService.removeSingleItem(product.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Icon(
                              Icons.remove, // Always show minus when quantity > 0
                              color: Colors.purple,
                              size: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            currentQuantityInCart.toString(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            cartService.addItem(product.id, product.name, product.imageUrl, product.currentPrice);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Icon(Icons.add, color: Colors.purple, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
} 