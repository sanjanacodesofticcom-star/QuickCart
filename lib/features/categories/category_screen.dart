import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/sticky_cart_bar.dart';
import '../../app/providers/catalog_provider.dart';
import 'category_products_screen.dart';

class CategoryScreen extends StatelessWidget {
  final void Function(int)? onNavigateTab;

  const CategoryScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        final categories = catalog.categories;

        return Scaffold(
          appBar: AppBar(
            title: const Text('All Categories'),
            backgroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final productCount = catalog.getProductsByCategory(cat.id).length;

                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryProductsScreen(category: cat),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(cat.id),
                              size: 28,
                              color: AppColors.secondary,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$productCount products',
                                style: const TextStyle(
                                  fontSize: 12,
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
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StickyCartBar(
                  onViewCart: () => onNavigateTab?.call(2),
                ),
              ),
            ],
          ),
        );
      },
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
