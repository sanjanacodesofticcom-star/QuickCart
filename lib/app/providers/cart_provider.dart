import 'package:flutter/foundation.dart';
import '../../core/models/product_model.dart';
import '../../core/models/cart_item_model.dart';
import '../../core/constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => Map.unmodifiable(_items);
  List<CartItem> get itemList => _items.values.toList();

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  int get totalItemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee {
    if (isEmpty) return 0.0;
    return subtotal >= AppConstants.freeDeliveryThreshold ? 0.0 : AppConstants.standardDeliveryFee;
  }

  double get totalSavings => _items.values.fold(0.0, (sum, item) => sum + item.totalSavings);

  double get total => subtotal + deliveryFee;

  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  bool canIncrease(String productId, int availableStock) {
    final currentQty = getQuantity(productId);
    return currentQty < availableStock;
  }

  void addToCart(Product product) {
    if (product.isOutOfStock) return;

    if (_items.containsKey(product.id)) {
      if (_items[product.id]!.quantity < product.stock) {
        _items[product.id]!.quantity += 1;
      }
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity < item.product.stock) {
        item.quantity += 1;
        notifyListeners();
      }
    }
  }

  void decreaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity -= 1;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
