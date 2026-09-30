import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/models/category_model.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/sticky_cart_bar.dart';
import '../../app/providers/catalog_provider.dart';
import '../../app/providers/user_provider.dart';
import '../products/product_detail_screen.dart';
import '../products/search_screen.dart';
import '../categories/category_products_screen.dart';
import '../admin/admin_shell.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CatalogProvider, UserProvider>(
      builder: (context, catalog, userProvider, _) {
        if (catalog.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),
          );
        }

        final user = userProvider.currentUser;
        final address = user?.defaultAddress?.fullAddress ?? 'Panchsheel Park, New Delhi - 110017';

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Top Header with Location & QuickCart Branding
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    backgroundColor: AppColors.primary,
                    expandedHeight: 120,
                    toolbarHeight: 60,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Delivery in ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                Text(
                                  '10 MINS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      // Admin Panel Access Button
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AdminShell()),
                          );
                        },
                        icon: const Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.secondary),
                        label: const Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Search "chips", "cold drink", "noodles"...',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Promotional Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF111827), Color(0xFF1F2937)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '⚡ FREE DELIVERY',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Craving a Snack Break?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Free delivery on orders above ₹299.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.local_shipping_rounded,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Categories Horizontal Strip
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Explore Categories',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => onNavigateTab(1), // Go to Categories Tab
                                child: const Text(
                                  'See All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: catalog.categories.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final cat = catalog.categories[index];
                              return _buildCategoryItem(context, cat);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Best Sellers Section
                  _buildSectionHeader('🔥 Best Sellers', 'Most ordered right now'),
                  _buildProductHorizontalList(context, catalog.bestSellers),

                  // Popular Picks Section
                  _buildSectionHeader('⭐ Popular Picks', 'Highly rated by customers'),
                  _buildProductHorizontalList(context, catalog.popularProducts),

                  // Snacks Section
                  _buildCategorySection(context, catalog, 'CAT001', '🍿 Crunchy Snacks'),

                  // Beverages Section
                  _buildCategorySection(context, catalog, 'CAT004', '🥤 Cold Beverages'),

                  // Instant Food & Noodles Section
                  _buildCategorySection(context, catalog, 'CAT006', '🍜 Instant Noodles & Ramen'),

                  // Chocolates & Cookies Section
                  _buildCategorySection(context, catalog, 'CAT003', '🍫 Chocolates & Sweet Cravings'),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // Spacing for Sticky Cart
                  ),
                ],
              ),

              // Sticky Cart CTA
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StickyCartBar(
                  onViewCart: () => onNavigateTab(2), // Go to Cart tab
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(category: category),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(category.id),
                color: AppColors.secondary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHorizontalList(BuildContext context, List<Product> products) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 250,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return SizedBox(
              width: 160,
              child: ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: product.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, CatalogProvider catalog, String categoryId, String title) {
    final products = catalog.getProductsByCategory(categoryId);
    if (products.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverMainAxisGroup(
      slivers: [
        _buildSectionHeader(title, '${products.length} items available'),
        _buildProductHorizontalList(context, products),
      ],
    );
  }

  IconData _getCategoryIcon(String catId) {
    switch (catId) {
      case 'CAT001': return Icons.lunch_dining_rounded;
      case 'CAT002': return Icons.cookie_rounded;
      case 'CAT003': return Icons.cake_rounded;
      case 'CAT004': return Icons.local_drink_rounded;
      case 'CAT005': return Icons.ramen_dining_rounded;
      case 'CAT006': return Icons.soup_kitchen_rounded;
      case 'CAT007': return Icons.grain_rounded;
      case 'CAT008': return Icons.bakery_dining_rounded;
      case 'CAT009': return Icons.egg_alt_rounded;
      case 'CAT010': return Icons.icecream_rounded;
      default: return Icons.category_rounded;
    }
  }
}
