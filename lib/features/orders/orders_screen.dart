import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../app/providers/order_provider.dart';
import '../../app/providers/user_provider.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/providers/catalog_provider.dart';
import 'order_tracking_screen.dart';
import '../cart/cart_screen.dart';

class OrdersScreen extends StatelessWidget {
  final bool isRootTab;

  const OrdersScreen({super.key, this.isRootTab = false});

  @override
  Widget build(BuildContext context) {
    return Consumer3<OrderProvider, UserProvider, CartProvider>(
      builder: (context, orderProvider, userProvider, cartProvider, _) {
        final user = userProvider.currentUser;
        final orders = user != null
            ? orderProvider.getCustomerOrders(user.id)
            : orderProvider.orders;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Orders'),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: !isRootTab,
          ),
          body: orders.isEmpty
              ? const EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders Yet',
                  message: 'You haven\'t placed any orders yet. When you do, they will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Order Number & Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.orderNumber,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              StatusBadge(status: order.orderStatus, isSmall: true),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.formatDateTime(order.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Divider(height: 20),

                          // Items List
                          ...order.items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${item.quantity}x',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.productName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.total),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(height: 20),

                          // Footer: Total & Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Paid',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(order.total),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Reorder Button
                                  OutlinedButton(
                                    onPressed: () {
                                      final catalog = Provider.of<CatalogProvider>(context, listen: false);
                                      for (final item in order.items) {
                                        final prod = catalog.getProductById(item.productId);
                                        if (prod != null && !prod.isOutOfStock) {
                                          cartProvider.addToCart(prod);
                                        }
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Items added to your cart!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const CartScreen()),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Reorder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 8),
                                  // Track Button
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => OrderTrackingScreen(orderId: order.id),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Track', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
