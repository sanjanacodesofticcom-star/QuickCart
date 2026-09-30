import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/order_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/status_badge.dart';
import '../../app/providers/order_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _statusFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<String> _allStatuses = const [
    'Placed',
    'Confirmed',
    'Preparing',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order ${order.orderNumber}'),
            StatusBadge(status: order.orderStatus, isSmall: true),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${order.customerName} (${order.phone})', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Address: ${order.address.fullAddress}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Placed On: ${DateFormatter.formatDateTime(order.createdAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Divider(height: 20),
              const Text('Items Ordered:', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ...order.items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${i.quantity}x ${i.productName}', style: const TextStyle(fontSize: 13)),
                        Text(CurrencyFormatter.format(i.total), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  )),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:'),
                  Text(CurrencyFormatter.format(order.subtotal)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery Fee:'),
                  Text(order.deliveryFee == 0 ? 'FREE' : CurrencyFormatter.format(order.deliveryFee)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.w900)),
                  Text(CurrencyFormatter.format(order.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              const Divider(height: 20),
              Text('Payment: ${order.paymentMethod} (${order.paymentStatus})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, Order order) {
    String selected = order.orderStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Update Status: ${order.orderNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _allStatuses.map((s) {
              final isSelected = selected == s;
              return InkWell(
                onTap: () => setModalState(() => selected = s),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.secondary)
                      else
                        const Icon(Icons.radio_button_unchecked_rounded, size: 20, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<OrderProvider>(context, listen: false).updateOrderStatus(order.id, selected);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order ${order.orderNumber} status changed to $selected')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
              ),
              child: const Text('Save Status'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        var orders = orderProvider.orders;

        if (_query.isNotEmpty) {
          final q = _query.toLowerCase().trim();
          orders = orders.where((o) {
            return o.orderNumber.toLowerCase().contains(q) ||
                o.customerName.toLowerCase().contains(q) ||
                o.phone.contains(q);
          }).toList();
        }

        if (_statusFilter != 'All') {
          orders = orders.where((o) => o.orderStatus == _statusFilter).toList();
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Order Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Track customer orders, update fulfillment status, and review payment states',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Search & Filter
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _query = val),
                        decoration: InputDecoration(
                          hintText: 'Search by order #, customer name, phone...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          items: [
                            const DropdownMenuItem(value: 'All', child: Text('All Statuses', style: TextStyle(fontSize: 13))),
                            ..._allStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))),
                          ],
                          onChanged: (val) => setState(() => _statusFilter = val ?? 'All'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Orders Table
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: orders.isEmpty
                        ? const Center(
                            child: Text('No orders match your filter.', style: TextStyle(color: AppColors.textSecondary)),
                          )
                        : ListView.separated(
                            itemCount: orders.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
                            itemBuilder: (context, index) {
                              final order = orders[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.receipt_rounded, size: 20, color: AppColors.secondary),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${order.orderNumber} • ${order.customerName}',
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          ),
                                          Text(
                                            '${order.items.length} items • ${order.phone}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            CurrencyFormatter.format(order.total),
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                          ),
                                          Text(
                                            '${order.paymentMethod} • ${order.paymentStatus}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: order.paymentStatus == 'Paid' ? AppColors.success : AppColors.warning,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: order.orderStatus, isSmall: true),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateFormatter.formatDateOnly(order.createdAt),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      tooltip: 'View Details',
                                      icon: const Icon(Icons.visibility_rounded, size: 18, color: AppColors.info),
                                      onPressed: () => _showOrderDetailsDialog(context, order),
                                    ),
                                    IconButton(
                                      tooltip: 'Update Status',
                                      icon: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.secondary),
                                      onPressed: () => _showStatusUpdateDialog(context, order),
                                    ),
                                    IconButton(
                                      tooltip: 'Cancel Order',
                                      icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                                      onPressed: order.orderStatus == 'Cancelled'
                                          ? null
                                          : () {
                                              orderProvider.cancelOrder(order.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Order ${order.orderNumber} cancelled')),
                                              );
                                            },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
