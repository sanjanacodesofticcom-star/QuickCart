import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/product_model.dart';

class ProductImageBadge extends StatelessWidget {
  final Product product;
  final double size;
  final double borderRadius;

  const ProductImageBadge({
    super.key,
    required this.product,
    this.size = 100,
    this.borderRadius = 12,
  });

  // Pick vibrant category colors and icons for high-fidelity fallback rendering
  (Color, Color, IconData) _getCategoryVisuals() {
    switch (product.categoryId) {
      case 'CAT001': // Snacks
        return (const Color(0xFFFEF3C7), const Color(0xFFD97706), Icons.lunch_dining_rounded);
      case 'CAT002': // Biscuits
        return (const Color(0xFFFDE68A), const Color(0xFFB45309), Icons.cookie_rounded);
      case 'CAT003': // Chocolates
        return (const Color(0xFFF3E8FF), const Color(0xFF7E22CE), Icons.cake_rounded);
      case 'CAT004': // Beverages
        return (const Color(0xFFE0F2FE), const Color(0xFF0284C7), Icons.local_drink_rounded);
      case 'CAT005': // Instant Food
        return (const Color(0xFFFFEDD5), const Color(0xFFEA580C), Icons.ramen_dining_rounded);
      case 'CAT006': // Noodles
        return (const Color(0xFFFFE4E6), const Color(0xFFE11D48), Icons.soup_kitchen_rounded);
      case 'CAT007': // Namkeen
        return (const Color(0xFFFEF9C3), const Color(0xFFCA8A04), Icons.grain_rounded);
      case 'CAT008': // Cookies
        return (const Color(0xFFF5E6D3), const Color(0xFF8B5E3C), Icons.bakery_dining_rounded);
      case 'CAT009': // Breakfast
        return (const Color(0xFFDCFCE7), const Color(0xFF16A34A), Icons.egg_alt_rounded);
      case 'CAT010': // Ice Cream
        return (const Color(0xFFFCE7F3), const Color(0xFFDB2777), Icons.icecream_rounded);
      default:
        return (const Color(0xFFF3F4F6), AppColors.secondary, Icons.shopping_bag_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, iconColor, icon) = _getCategoryVisuals();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Centered stylized vector icon with product initial / pattern
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: size * 0.42,
                  color: iconColor,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.unit.toUpperCase(),
                    style: TextStyle(
                      fontSize: size * 0.1,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Discount Badge
          if (product.discountPercentage > 0)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${product.discountPercentage.toInt()}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          // Out of stock overlay
          if (product.isOutOfStock)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'OUT OF STOCK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
