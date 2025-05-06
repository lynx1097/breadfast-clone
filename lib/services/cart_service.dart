import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });
}

class CartService with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  static const double deliveryFee = 30.0;

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length; // Number of unique items

  // Total number of all pieces in the cart
  int get totalIndividualItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get itemsTotalPrice {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  double get grandTotalPrice => itemsTotalPrice + (itemCount > 0 ? deliveryFee : 0.0);

  void addItem(String productId, String name, String imageUrl, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          imageUrl: existingCartItem.imageUrl,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          imageUrl: imageUrl,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  // Decrements quantity or removes if quantity is 1
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          imageUrl: existingCartItem.imageUrl,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Removes the item entry completely, regardless of quantity
  void removeItemCompletely(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
} 