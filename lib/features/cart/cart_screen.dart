import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/product_image_badge.dart';
import '../../core/widgets/quantity_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../app/providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final bool isRootTab;

  const CartScreen({super.key, this.isRootTab = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Cart'),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: !isRootTab,
            actions: [
              if (cart.isNotEmpty)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Cart'),
                        content: const Text('Are you sure you want to remove all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          body: cart.isEmpty
              ? EmptyStateView(
                  icon: Icons.shopping_basket_outlined,
                  title: 'Your cart is empty',
                  message: 'Looks like you haven\'t added any snacks or drinks yet. Start exploring our lightning fast catalog!',
                  actionLabel: 'Start Shopping',
                  onAction: () {
                    if (isRootTab) {
                      // Navigate to home tab via parent shell
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Free Delivery Progress Banner
                      _buildDeliveryBanner(cart),
                      const SizedBox(height: 16),

                      // Cart Items Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cart.itemList.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                          itemBuilder: (context, index) {
                            final item = cart.itemList[index];
                            final product = item.product;

                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ProductImageBadge(product: product, size: 60, borderRadius: 10),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          product.weight,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormatter.format(item.totalPrice),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  QuantityButton(
                                    quantity: item.quantity,
                                    stock: product.stock,
                                    isCompact: true,
                                    onAdd: () => cart.addToCart(product),
                                    onIncrease: () => cart.increaseQuantity(product.id),
                                    onDecrease: () => cart.decreaseQuantity(product.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bill Summary Card
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
                              'Bill Details',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildBillRow('Items Subtotal', CurrencyFormatter.format(cart.subtotal)),
                            const SizedBox(height: 8),
                            _buildBillRow(
                              'Delivery Fee',
                              cart.deliveryFee == 0
                                  ? 'FREE'
                                  : CurrencyFormatter.format(cart.deliveryFee),
                              isFree: cart.deliveryFee == 0,
                            ),
                            if (cart.totalSavings > 0) ...[
                              const SizedBox(height: 8),
                              _buildBillRow(
                                'Discount Savings',
                                '-${CurrencyFormatter.format(cart.totalSavings)}',
                                isHighlight: true,
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(color: AppColors.border),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'To Pay',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(cart.total),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          bottomSheet: cart.isEmpty
              ? null
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(top: BorderSide(color: AppColors.border)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(cart.total),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDeliveryBanner(CartProvider cart) {
    final subtotal = cart.subtotal;
    final threshold = AppConstants.freeDeliveryThreshold;
    final isFree = subtotal >= threshold;
    final remaining = (threshold - subtotal).clamp(0, threshold);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFree ? AppColors.successLight : AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFree ? AppColors.success.withValues(alpha: 0.3) : AppColors.primary,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFree ? Icons.check_circle_rounded : Icons.local_shipping_rounded,
            color: isFree ? AppColors.success : AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isFree
                  ? 'Yay! You unlocked FREE Delivery on this order.'
                  : 'Add ₹${remaining.toInt()} more to get FREE Delivery!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isFree ? AppColors.success : AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isFree = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isHighlight ? AppColors.success : AppColors.textSecondary,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isFree
                ? AppColors.success
                : (isHighlight ? AppColors.success : AppColors.text),
          ),
        ),
      ],
    );
  }
}
