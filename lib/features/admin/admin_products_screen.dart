import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/product_image_badge.dart';
import '../../core/widgets/status_badge.dart';
import '../../app/providers/catalog_provider.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategory;
  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQuickStockDialog(BuildContext context, Product product) {
    final stockController = TextEditingController(text: '${product.stock}');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Stock: ${product.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Stock: ${product.stock} units', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'New Stock Quantity',
                  hintText: 'e.g. 50',
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
                final newStock = int.parse(stockController.text.trim());
                Provider.of<CatalogProvider>(context, listen: false).updateStock(product.id, newStock);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stock updated for ${product.name} to $newStock')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<CatalogProvider>(context, listen: false).deleteProduct(product.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${product.name}"'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
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

        // Apply Search
        if (_query.isNotEmpty) {
          final q = _query.toLowerCase().trim();
          products = products.where((p) {
            return p.name.toLowerCase().contains(q) ||
                p.sku.toLowerCase().contains(q) ||
                p.categoryName.toLowerCase().contains(q);
          }).toList();
        }

        // Apply Category
        if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
          products = products.where((p) => p.categoryId == _selectedCategory).toList();
        }

        // Apply Status Filter
        if (_statusFilter == 'Active') {
          products = products.where((p) => p.isActive).toList();
        } else if (_statusFilter == 'Inactive') {
          products = products.where((p) => !p.isActive).toList();
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Management',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          'Showing ${products.length} of ${catalog.products.length} products',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminProductFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add New Product'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search and Filters Bar
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _query = val),
                        decoration: InputDecoration(
                          hintText: 'Search by product name, SKU, category...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Category Dropdown Filter
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButton<String?>(
                          value: _selectedCategory,
                          hint: const Text('All Categories', style: TextStyle(fontSize: 13)),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Categories', style: TextStyle(fontSize: 13)),
                            ),
                            for (final c in catalog.categories)
                              DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.name, style: const TextStyle(fontSize: 13)),
                              ),
                          ],
                          onChanged: (val) => setState(() => _selectedCategory = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Dropdown Filter
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
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Status', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Active', child: Text('Active Only', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Inactive', child: Text('Inactive Only', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (val) => setState(() => _statusFilter = val ?? 'All'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Products Table View
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
                              'No products match your filters.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    ProductImageBadge(product: product, size: 48, borderRadius: 8),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: AppColors.text,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'ID: ${product.id} • SKU: ${product.sku} • ${product.categoryName}',
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
                                            CurrencyFormatter.format(product.price),
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          ),
                                          Text(
                                            'Stock: ${product.stock} (${product.unit})',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: product.isOutOfStock ? AppColors.error : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: product.isActive ? 'ACTIVE' : 'INACTIVE', isSmall: true),
                                    const SizedBox(width: 8),
                                    StatusBadge(status: product.stockStatus, isSmall: true),
                                    const SizedBox(width: 12),
                                    // Action Buttons
                                    IconButton(
                                      tooltip: 'Quick Stock Update',
                                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18, color: AppColors.info),
                                      onPressed: () => _showQuickStockDialog(context, product),
                                    ),
                                    IconButton(
                                      tooltip: product.isActive ? 'Deactivate' : 'Activate',
                                      icon: Icon(
                                        product.isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                        size: 18,
                                        color: product.isActive ? AppColors.success : AppColors.textMuted,
                                      ),
                                      onPressed: () => catalog.toggleProductActive(product.id),
                                    ),
                                    IconButton(
                                      tooltip: 'Edit Product',
                                      icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.secondary),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AdminProductFormScreen(product: product),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Delete Product',
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                      onPressed: () => _showDeleteConfirmation(context, product),
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
