import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../app/providers/catalog_provider.dart';
import '../../app/providers/order_provider.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CatalogProvider, OrderProvider>(
      builder: (context, catalog, orderProvider, _) {
        final totalRevenue = orderProvider.totalRevenue;
        final orders = orderProvider.orders;
        final products = catalog.products;

        // Calculate category sales breakdown from orders
        final Map<String, int> categoryQuantityMap = {};
        final Map<String, double> categoryRevenueMap = {};

        for (final order in orders) {
          if (order.orderStatus == 'Cancelled') continue;
          for (final item in order.items) {
            final prod = catalog.getProductById(item.productId);
            final catName = prod?.categoryName ?? 'Other';

            categoryQuantityMap[catName] = (categoryQuantityMap[catName] ?? 0) + item.quantity;
            categoryRevenueMap[catName] = (categoryRevenueMap[catName] ?? 0.0) + item.total;
          }
        }

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales & Catalog Analytics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Aggregated revenue, category volume, and inventory health metrics',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Top Highlights Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF111827), Color(0xFF1F2937)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHighlightItem('Total Gross Sales', CurrencyFormatter.format(totalRevenue), AppColors.primary),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildHighlightItem('Avg. Order Value', CurrencyFormatter.format(orders.isNotEmpty ? totalRevenue / orders.length : 0), Colors.white),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildHighlightItem('Catalog Size', '${products.length} SKUs', Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Category Revenue Breakdown Card
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
                        'Category Volume & Sales Breakdown',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      if (categoryRevenueMap.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('No sales recorded yet', style: TextStyle(color: AppColors.textSecondary))),
                        )
                      else
                        ...categoryRevenueMap.entries.map((e) {
                          final count = categoryQuantityMap[e.key] ?? 0;
                          final pct = totalRevenue > 0 ? (e.value / totalRevenue) : 0.0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${e.key} ($count units sold)',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(e.value),
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct.clamp(0.05, 1.0),
                                    minHeight: 6,
                                    backgroundColor: AppColors.surface,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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

  Widget _buildHighlightItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
