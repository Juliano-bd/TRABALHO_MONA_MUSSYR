import 'package:flutter/material.dart';
import '../services/product_service.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  double _discount = 0.0;
  final double _shippingCost = 13.00;
  bool _couponApplied = false;

  List<CartItem> get items => _items;
  double get shippingCost => _items.isEmpty ? 0.0 : _shippingCost;
  double get discount => _discount;
  bool get couponApplied => _couponApplied;

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }
  double get total => (subtotal + shippingCost) - _discount;

  void addToCart(Product product) {
    int index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _discount = 0.0;
    _couponApplied = false;
    notifyListeners();
  }

  int get totalItemCount {
  return _items.fold(0, (sum, item) => sum + item.quantity);
}

 void applyCoupon(String coupon) {
    // Altera JOIA10 para AMOR10
    if (coupon.toUpperCase() == 'AMOR10' || coupon.toUpperCase() == 'SEXY10') {
      _discount = subtotal * 0.10;
      _couponApplied = true;
    } else if (coupon.toUpperCase() == 'FRETEGRATIS') {
      _couponApplied = true;
    } else {
      _discount = 0.0;
      _couponApplied = false;
    }
    notifyListeners();
  }
}