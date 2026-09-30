import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/category_model.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/sticky_cart_bar.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../app/providers/catalog_provider.dart';
import '../products/product_detail_screen.dart';
import '../cart/cart_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String _selectedSort = 'Default';
  bool _inStockOnly = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        var products = catalog.getProductsByCategory(widget.category.id);

        if (_inStockOnly) {
          products = products.where((p) => !p.isOutOfStock).toList();
        }

        if (_selectedSort == 'Price: Low to High') {
          products.sort((a, b) => a.price.compareTo(b.price));
        } else if (_selectedSort == 'Price: High to Low') {
          products.sort((a, b) => b.price.compareTo(a.price));
        } else if (_selectedSort == 'Top Rated') {
          products.sort((a, b) => b.rating.compareTo(a.rating));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.category.name),
            backgroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Filter Chips
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: Colors.white,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSortMenu(),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('In Stock Only'),
                          selected: _inStockOnly,
                          onSelected: (val) => setState(() => _inStockOnly = val),
                          selectedColor: AppColors.primary,
                          checkmarkColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _inStockOnly ? AppColors.secondary : AppColors.textSecondary,
                          ),
                          backgroundColor: AppColors.surface,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  // Products Grid
                  Expanded(
                    child: products.isEmpty
                        ? const EmptyStateView(
                            icon: Icons.inventory_2_outlined,
                            title: 'No Products in this Category',
                            message: 'Try changing your filter or check other categories.',
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(productId: product.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StickyCartBar(
                  onViewCart: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      initialValue: _selectedSort,
      onSelected: (val) => setState(() => _selectedSort = val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Default', child: Text('Default')),
        const PopupMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
        const PopupMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
        const PopupMenuItem(value: 'Top Rated', child: Text('Top Rated')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _selectedSort != 'Default' ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 16,
              color: _selectedSort != 'Default' ? AppColors.secondary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _selectedSort == 'Default' ? 'Sort By' : _selectedSort,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _selectedSort != 'Default' ? AppColors.secondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
