import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/sticky_cart_bar.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../app/providers/catalog_provider.dart';
import 'product_detail_screen.dart';
import '../cart/cart_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategory;
  bool _inStockOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        var results = catalog.searchProducts(_query, categoryId: _selectedCategory);

        if (_inStockOnly) {
          results = results.where((p) => !p.isOutOfStock).toList();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            titleSpacing: 0,
            title: Container(
              height: 44,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _query = val),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Search products, snacks, drinks...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Category Filter Chips
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: Colors.white,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: const Text('All Categories'),
                          selected: _selectedCategory == null,
                          onSelected: (_) => setState(() => _selectedCategory = null),
                          selectedColor: AppColors.primary,
                          checkmarkColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _selectedCategory == null ? AppColors.secondary : AppColors.textSecondary,
                          ),
                          backgroundColor: AppColors.surface,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(width: 8),
                        for (final cat in catalog.categories) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat.name),
                              selected: _selectedCategory == cat.id,
                              onSelected: (_) => setState(() {
                                _selectedCategory = (_selectedCategory == cat.id) ? null : cat.id;
                              }),
                              selectedColor: AppColors.primary,
                              checkmarkColor: AppColors.secondary,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _selectedCategory == cat.id ? AppColors.secondary : AppColors.textSecondary,
                              ),
                              backgroundColor: AppColors.surface,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  // Results header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${results.length} ${results.length == 1 ? 'Product' : 'Products'} found',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _inStockOnly = !_inStockOnly),
                          borderRadius: BorderRadius.circular(4),
                          child: Row(
                            children: [
                              Icon(
                                _inStockOnly ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                size: 18,
                                color: _inStockOnly ? AppColors.secondary : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'In Stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Results Grid
                  Expanded(
                    child: results.isEmpty
                        ? EmptyStateView(
                            icon: Icons.search_off_rounded,
                            title: 'No products found',
                            message: 'We couldn\'t find anything matching "$_query". Try checking for typos or searching by category.',
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final product = results[index];
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
}
