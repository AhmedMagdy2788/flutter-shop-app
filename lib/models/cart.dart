import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String? title;
  final String productID;
  int productAmount;
  double productPrice;

  CartItem({
    required this.id,
    this.title,
    required this.productID,
    required this.productPrice,
    this.productAmount = 0,
  });
}

class Cart with ChangeNotifier {
  final String? token;
  Cart(this.token);
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems {
    return [..._cartItems];
  }

  int get itemsCount {
    return _cartItems.length;
  }

  double get totalCartPrice {
    double total = 0.0;
    _cartItems.forEach((item) {
      total += item.productPrice * item.productAmount;
    });
    return total;
  }

  void addProductToCart(String productID, int amount, double pricePerPiece) {
    List<CartItem> existingItems = _cartItems.where((item) {
      if (item.productID == productID)
        return true;
      else
        return false;
    }).toList();
    if (existingItems.length > 0) {
      existingItems[0].productAmount += amount;
      existingItems[0].productPrice += pricePerPiece;
    } else {
      _cartItems.add(CartItem(
        id: '${DateTime.now()}',
        productID: productID,
        productAmount: amount,
        productPrice: pricePerPiece,
      ));
    }
    notifyListeners();
  }

  void removeProductToCart(String productID) {
    _cartItems.removeWhere((item) {
      if (item.productID == productID)
        return true;
      else
        return false;
    });
    notifyListeners();
  }

  bool removeProductItemFromCart(String productId) {
    var cartItem = _cartItems.firstWhere((cartItem) {
      if (cartItem.productID == productId)
        return true;
      else
        return false;
    });
    if (cartItem == null) return false;
    if (cartItem.productAmount > 1)
      cartItem.productAmount--;
    else {
      removeProductToCart(productId);
    }
    notifyListeners();
    return true;
  }

  int getProductAmount(String prodID) {
    CartItem? cartItem = _cartItems.firstWhere((cartItem) {
      if (cartItem.productID == prodID)
        return true;
      else
        return false;
    });
    if (cartItem == null) return 0;
    return cartItem.productAmount;
  }

  void clear() {
    _cartItems = [];
    notifyListeners();
  }
}
