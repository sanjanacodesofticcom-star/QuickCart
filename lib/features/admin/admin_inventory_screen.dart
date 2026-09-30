import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/widgets/product_image_badge.dart';
import '../../core/widgets/status_badge.dart';
import '../../app/providers/catalog_provider.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  String _filter = 'All'; // 'All', 'In Stock', 'Low Stock', 'Out of Stock'
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditStockDialog(BuildContext context, Product product) {
    final controller = TextEditingController(text: '${product.stock}');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adjust Stock: ${product.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SKU: ${product.sku} • Threshold: ${product.lowStockThreshold}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Available Units',
                  hintText: 'Enter stock count',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Stock is required';
                  final parsed = int.tryParse(val.trim());
                  if (parsed == null || parsed < 0) return 'Must be 0 or greater';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newStock = int.parse(controller.text.trim());
                Provider.of<CatalogProvider>(context, listen: false).updateStock(product.id, newStock);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stock updated to $newStock units')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
            ),
            child: const Text('Save Stock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        var products = catalog.products;

        if (_query.isNotEmpty) {
          final q = _query.toLowerCase().trim();
          products = products.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)).toList();
        }

        if (_filter == 'In Stock') {
          products = products.where((p) => p.isInStock).toList();
        } else if (_filter == 'Low Stock') {
          products = products.where((p) => p.isLowStock).toList();
        } else if (_filter == 'Out of Stock') {
          products = products.where((p) => p.isOutOfStock).toList();
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Inventory Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Monitor stock counts, thresholds, and adjust inventory in real time',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Search & Filter Tabs
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _query = val),
                        decoration: InputDecoration(
                          hintText: 'Search by product name or SKU...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ...['All', 'In Stock', 'Low Stock', 'Out of Stock'].map((f) {
                      final isSelected = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor: AppColors.primary,
                          checkmarkColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // Table
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: products.isEmpty
                        ? const Center(
                            child: Text(
                              'No products match the selected inventory filter.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    ProductImageBadge(product: product, size: 44, borderRadius: 8),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'SKU: ${product.sku} • Category: ${product.categoryName}',
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
                                            'Stock: ${product.stock} ${product.unit}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: product.isOutOfStock
                                                  ? AppColors.error
                                                  : (product.isLowStock ? AppColors.warning : AppColors.text),
                                            ),
                                          ),
                                          Text(
                                            'Low Threshold: ${product.lowStockThreshold}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: product.stockStatus, isSmall: true),
                                    const SizedBox(width: 16),
                                    // Stock Adjuster Button
                                    ElevatedButton.icon(
                                      onPressed: () => _showEditStockDialog(context, product),
                                      icon: const Icon(Icons.edit_rounded, size: 14),
                                      label: const Text('Update'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.surface,
                                        foregroundColor: AppColors.secondary,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
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
