import '../../core/models/order_model.dart';
import '../../core/services/json_data_service.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order?> getOrderById(String id);
  Future<List<Order>> getOrdersByCustomer(String customerId);
  Future<void> createOrder(Order order);
  Future<void> updateOrderStatus(String orderId, String newStatus);
  Future<void> cancelOrder(String orderId);
}

class JsonOrderRepository implements OrderRepository {
  final JsonDataService _jsonDataService;
  List<Order> _ordersCache = [];
  bool _isInitialized = false;

  JsonOrderRepository({JsonDataService? jsonDataService})
      : _jsonDataService = jsonDataService ?? JsonDataService();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _ordersCache = await _jsonDataService.loadOrders();
      _isInitialized = true;
    }
  }

  @override
  Future<List<Order>> getOrders() async {
    await _ensureInitialized();
    return List<Order>.unmodifiable(_ordersCache);
  }

  @override
  Future<Order?> getOrderById(String id) async {
    await _ensureInitialized();
    try {
      return _ordersCache.firstWhere((o) => o.id == id || o.orderNumber == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Order>> getOrdersByCustomer(String customerId) async {
    await _ensureInitialized();
    return _ordersCache
        .where((o) => o.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> createOrder(Order order) async {
    await _ensureInitialized();
    _ordersCache.insert(0, order);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _ensureInitialized();
    final index = _ordersCache.indexWhere((o) => o.id == orderId || o.orderNumber == orderId);
    if (index != -1) {
      _ordersCache[index] = _ordersCache[index].copyWith(orderStatus: newStatus);
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'Cancelled');
  }
}
