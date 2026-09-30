class AppConstants {
  static const String appName = 'QuickCart';
  static const String appTagline = 'Groceries in 10 minutes';
  static const String currency = 'INR';
  static const String currencySymbol = '₹';
  static const double standardDeliveryFee = 20.0;
  static const double freeDeliveryThreshold = 299.0;
  static const int estimatedDeliveryMinutes = 10;
  
  // Storage keys
  static const String keyProducts = 'quickcart_products_data';
  static const String keyOrders = 'quickcart_orders_data';
  static const String keyCart = 'quickcart_cart_data';
  static const String keyUser = 'quickcart_current_user';
  static const String keyAdminAuth = 'quickcart_admin_logged_in';
}
