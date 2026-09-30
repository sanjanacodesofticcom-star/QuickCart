import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/status_badge.dart';
import '../../app/providers/order_provider.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  final List<Map<String, dynamic>> _steps = const [
    {
      'status': 'Placed',
      'title': 'Order Placed',
      'subtitle': 'Your order has been received by the store',
      'icon': Icons.receipt_rounded,
    },
    {
      'status': 'Confirmed',
      'title': 'Order Confirmed',
      'subtitle': 'Store confirmed availability of items',
      'icon': Icons.thumb_up_rounded,
    },
    {
      'status': 'Preparing',
      'title': 'Preparing Your Bag',
      'subtitle': 'Items are being packed with care',
      'icon': Icons.inventory_2_rounded,
    },
    {
      'status': 'Out for Delivery',
      'title': 'Out for Delivery',
      'subtitle': 'Rider is on the way to your address',
      'icon': Icons.delivery_dining_rounded,
    },
    {
      'status': 'Delivered',
      'title': 'Delivered',
      'subtitle': 'Order handed over successfully',
      'icon': Icons.check_circle_rounded,
    },
  ];

  int _getStatusStepIndex(String status) {
    switch (status) {
      case 'Placed': return 0;
      case 'Confirmed': return 1;
      case 'Preparing': return 2;
      case 'Out for Delivery': return 3;
      case 'Delivered': return 4;
      case 'Cancelled': return -1;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final order = orderProvider.getOrderById(orderId);

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Track Order')),
            body: const Center(child: Text('Order not found')),
          );
        }

        final currentStepIndex = _getStatusStepIndex(order.orderStatus);
        final isCancelled = order.orderStatus == 'Cancelled';

        return Scaffold(
          appBar: AppBar(
            title: Text('Track ${order.orderNumber}'),
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Delivery Progress Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCancelled ? AppColors.errorLight : AppColors.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCancelled ? AppColors.error : AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCancelled ? Icons.cancel_rounded : Icons.electric_bolt_rounded,
                          color: isCancelled ? Colors.white : AppColors.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCancelled ? 'Order Cancelled' : 'Arriving in ~10 Mins',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isCancelled ? AppColors.error : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCancelled
                                  ? 'This order was cancelled.'
                                  : 'Status: ${order.orderStatus}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isCancelled ? AppColors.error : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: order.orderStatus, isSmall: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Order Tracking Stepper
                if (!isCancelled) ...[
                  const Text(
                    'Order Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_steps.length, (index) {
                    final step = _steps[index];
                    final isCompleted = index <= currentStepIndex;
                    final isCurrent = index == currentStepIndex;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step Indicator & Line
                          Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? (isCurrent ? AppColors.primary : AppColors.success)
                                      : AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCompleted ? Colors.transparent : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  step['icon'] as IconData,
                                  size: 18,
                                  color: isCompleted
                                      ? (isCurrent ? AppColors.secondary : Colors.white)
                                      : AppColors.textMuted,
                                ),
                              ),
                              if (index < _steps.length - 1)
                                Expanded(
                                  child: Container(
                                    width: 2.5,
                                    color: index < currentStepIndex
                                        ? AppColors.success
                                        : AppColors.border,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Step Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['title'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.w700 : FontWeight.w500),
                                      color: isCompleted ? AppColors.text : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCompleted ? AppColors.textSecondary : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Delivery Address Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Address',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 18, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.address.fullAddress,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Placed on', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(DateFormatter.formatDateTime(order.createdAt), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment (${order.paymentMethod})', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(order.paymentStatus, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: order.paymentStatus == 'Paid' ? AppColors.success : AppColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
