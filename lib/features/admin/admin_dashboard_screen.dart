import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/status_badge.dart';
import '../../app/providers/catalog_provider.dart';
import '../../app/providers/order_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  final void Function(int) onNavigate;

  const AdminDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CatalogProvider, OrderProvider>(
      builder: (context, catalog, orderProvider, _) {
        final totalRev = orderProvider.totalRevenue;
        final totalOrders = orderProvider.totalOrdersCount;
        final pendingOrders = orderProvider.pendingOrdersCount;
        final deliveredOrders = orderProvider.deliveredOrdersCount;

        final totalProducts = catalog.totalProductsCount;
        final activeProducts = catalog.activeProductsCount;
        final lowStock = catalog.lowStockProductsCount;
        final outOfStock = catalog.outOfStockProductsCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Welcome Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Store Performance Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Real-time metrics calculated from master store data',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => onNavigate(1), // Go to Products
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Metric Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final count = isWide ? 4 : 2;

                  return GridView.count(
                    crossAxisCount: count,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 1.6 : 1.3,
                    children: [
                      _buildMetricCard(
                        title: 'Total Revenue',
                        value: CurrencyFormatter.format(totalRev),
                        subtitle: '$deliveredOrders orders fulfilled',
                        icon: Icons.currency_rupee_rounded,
                        color: AppColors.success,
                        bgColor: AppColors.successLight,
                      ),
                      _buildMetricCard(
                        title: 'Total Orders',
                        value: '$totalOrders',
                        subtitle: '$pendingOrders pending processing',
                        icon: Icons.shopping_cart_rounded,
                        color: AppColors.info,
                        bgColor: AppColors.infoLight,
                        onTap: () => onNavigate(4), // Go to Orders
                      ),
                      _buildMetricCard(
                        title: 'Active Products',
                        value: '$activeProducts / $totalProducts',
                        subtitle: 'Live in catalog',
                        icon: Icons.inventory_2_rounded,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        onTap: () => onNavigate(1), // Go to Products
                      ),
                      _buildMetricCard(
                        title: 'Stock Alerts',
                        value: '${lowStock + outOfStock}',
                        subtitle: '$outOfStock out of stock, $lowStock low',
                        icon: Icons.warning_amber_rounded,
                        color: outOfStock > 0 ? AppColors.error : AppColors.warning,
                        bgColor: outOfStock > 0 ? AppColors.errorLight : AppColors.warningLight,
                        onTap: () => onNavigate(3), // Go to Inventory
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Two Column section: Low Stock Alert & Recent Orders
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 900;

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLowStockSection(context, catalog)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRecentOrdersSection(context, orderProvider)),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _buildLowStockSection(context, catalog),
                      const SizedBox(height: 16),
                      _buildRecentOrdersSection(context, orderProvider),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection(BuildContext context, CatalogProvider catalog) {
    final lowStockItems = catalog.lowStockProducts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Low Stock Warnings',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => onNavigate(3), // Go to Inventory
                child: const Text('Manage Stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const Divider(height: 12),
          if (lowStockItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('All products are adequately stocked! 👍', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lowStockItems.take(5).length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final prod = lowStockItems[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'SKU: ${prod.sku} • Threshold: ${prod.lowStockThreshold}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: prod.stockStatus, isSmall: true),
                      const SizedBox(width: 8),
                      Text(
                        '${prod.stock} left',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection(BuildContext context, OrderProvider orderProvider) {
    final recentOrders = orderProvider.orders.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.receipt_long_rounded, color: AppColors.secondary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recent Store Orders',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => onNavigate(4), // Go to Orders
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const Divider(height: 12),
          if (recentOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No orders recorded yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentOrders.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final order = recentOrders[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.orderNumber} • ${order.customerName}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormatter.formatDateTime(order.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: order.orderStatus, isSmall: true),
                      const SizedBox(width: 10),
                      Text(
                        CurrencyFormatter.format(order.total),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
