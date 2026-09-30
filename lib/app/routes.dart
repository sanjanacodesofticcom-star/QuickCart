import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/customer_shell.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/admin/admin_shell.dart';
import '../features/products/search_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String customer = '/customer';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String search = '/search';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        customer: (_) => const CustomerShell(),
        cart: (_) => const CartScreen(),
        checkout: (_) => const CheckoutScreen(),
        orders: (_) => const OrdersScreen(),
        search: (_) => const SearchScreen(),
        admin: (_) => const AdminShell(),
      };
}
