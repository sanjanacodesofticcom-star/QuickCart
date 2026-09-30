import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
  double get totalComparePrice => product.compareAtPrice * quantity;
  double get totalSavings => (product.compareAtPrice > product.price) 
      ? (product.compareAtPrice - product.price) * quantity 
      : 0.0;

  bool get canIncrease => quantity < product.stock;
  bool get canDecrease => quantity > 1;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
