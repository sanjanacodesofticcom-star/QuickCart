import 'package:flutter/foundation.dart';
import '../../core/models/order_model.dart';
import '../../core/models/user_model.dart';
import '../../core/models/cart_item_model.dart';
import '../../data/repositories/order_repository.dart';
import 'catalog_provider.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  OrderProvider({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? JsonOrderRepository() {
    loadOrders();
  }

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Admin Dashboard Metrics
  int get totalOrdersCount => _orders.length;
  int get pendingOrdersCount => _orders.where((o) => o.orderStatus != 'Delivered' && o.orderStatus != 'Cancelled').length;
  int get deliveredOrdersCount => _orders.where((o) => o.orderStatus == 'Delivered').length;
  int get cancelledOrdersCount => _orders.where((o) => o.orderStatus == 'Cancelled').length;
  double get totalRevenue => _orders.where((o) => o.orderStatus != 'Cancelled').fold(0.0, (sum, o) => sum + o.total);

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderRepository.getOrders();
    } catch (e) {
      _error = 'Failed to load orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Order> getCustomerOrders(String customerId) {
    return _orders.where((o) => o.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id || o.orderNumber == id);
    } catch (_) {
      return null;
    }
  }

  Future<Order> placeOrder({
    required User user,
    required OrderAddress address,
    required List<CartItem> cartItems,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double total,
    required String paymentMethod,
    required CatalogProvider catalogProvider,
  }) async {
    final nextNumber = 1000 + _orders.length + 1;
    final orderNumber = '#QC$nextNumber';
    final orderId = 'ORD${nextNumber.toString().padLeft(3, '0')}';

    final orderItems = cartItems.map((ci) {
      return OrderItem(
        productId: ci.product.id,
        productName: ci.product.name,
        quantity: ci.quantity,
        price: ci.product.price,
        total: ci.totalPrice,
        image: ci.product.image,
      );
    }).toList();

    // Deduct stock in catalog
    for (final ci in cartItems) {
      final newStock = (ci.product.stock - ci.quantity).clamp(0, 999999);
      await catalogProvider.updateStock(ci.product.id, newStock);
    }

    final newOrder = Order(
      id: orderId,
      orderNumber: orderNumber,
      customerId: user.id,
      customerName: user.name,
      phone: user.phone,
      address: address,
      items: orderItems,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'Online' ? 'Paid' : 'Pending',
      orderStatus: 'Placed',
      createdAt: DateTime.now().toIso8601String(),
    );

    await _orderRepository.createOrder(newOrder);
    _orders = await _orderRepository.getOrders();
    notifyListeners();
    return newOrder;
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _orderRepository.updateOrderStatus(orderId, newStatus);
    _orders = await _orderRepository.getOrders();
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId) async {
    await _orderRepository.cancelOrder(orderId);
    _orders = await _orderRepository.getOrders();
    notifyListeners();
  }
}
