import 'package:flutter_test/flutter_test.dart';
import 'package:quickcart/main.dart';
import 'package:quickcart/core/models/product_model.dart';
import 'package:quickcart/app/providers/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickCart Widget & App Flow Tests', () {
    testWidgets('QuickCartApp launches and displays Splash branding', (WidgetTester tester) async {
      await tester.pumpWidget(const QuickCartApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('QuickCart'), findsOneWidget);
      expect(find.text('Groceries in 10 minutes'), findsOneWidget);

      // Advance time past splash navigation (2.5s)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });

  group('Cart Calculation & Logic Unit Tests', () {
    final demoProduct1 = Product(
      id: 'P001',
      sku: 'SNK-001',
      name: 'Classic Salted Potato Chips',
      slug: 'classic-salted-potato-chips',
      categoryId: 'CAT001',
      categoryName: 'Snacks',
      description: 'Crispy salted potato chips',
      shortDescription: 'Classic chips',
      price: 30.0,
      compareAtPrice: 35.0,
      discountPercentage: 14.0,
      unit: 'pack',
      weight: '52 g',
      stock: 10,
      lowStockThreshold: 3,
      image: 'assets/images/products/P001.png',
      images: ['assets/images/products/P001.png'],
      isActive: true,
      isFeatured: true,
      isBestSeller: true,
      rating: 4.5,
      reviewCount: 120,
      tags: ['chips', 'snacks'],
      createdAt: '2026-09-30',
      updatedAt: '2026-09-30',
    );

    final demoProduct2 = Product(
      id: 'P002',
      sku: 'SNK-002',
      name: 'Masala Potato Chips',
      slug: 'masala-potato-chips',
      categoryId: 'CAT001',
      categoryName: 'Snacks',
      description: 'Spicy masala chips',
      shortDescription: 'Masala chips',
      price: 300.0,
      compareAtPrice: 350.0,
      discountPercentage: 14.0,
      unit: 'pack',
      weight: '52 g',
      stock: 5,
      lowStockThreshold: 2,
      image: 'assets/images/products/P002.png',
      images: ['assets/images/products/P002.png'],
      isActive: true,
      isFeatured: false,
      isBestSeller: false,
      rating: 4.6,
      reviewCount: 95,
      tags: ['chips'],
      createdAt: '2026-09-30',
      updatedAt: '2026-09-30',
    );

    test('Adding products updates item count and subtotal', () {
      final cart = CartProvider();
      expect(cart.isEmpty, isTrue);

      cart.addToCart(demoProduct1);
      expect(cart.totalItemCount, 1);
      expect(cart.subtotal, 30.0);
      // Below 299 -> ₹20 delivery fee
      expect(cart.deliveryFee, 20.0);
      expect(cart.total, 50.0);
    });

    test('Subtotal >= 299 qualifies for free delivery (₹0)', () {
      final cart = CartProvider();
      cart.addToCart(demoProduct2); // ₹300
      expect(cart.subtotal, 300.0);
      expect(cart.deliveryFee, 0.0);
      expect(cart.total, 300.0);
    });

    test('Quantity cannot exceed product stock', () {
      final cart = CartProvider();
      // demoProduct2 stock is 5
      for (int i = 0; i < 10; i++) {
        cart.addToCart(demoProduct2);
      }
      expect(cart.getQuantity(demoProduct2.id), 5);
      expect(cart.canIncrease(demoProduct2.id, demoProduct2.stock), isFalse);
    });

    test('Decreasing to 0 removes item from cart', () {
      final cart = CartProvider();
      cart.addToCart(demoProduct1);
      expect(cart.totalItemCount, 1);
      cart.decreaseQuantity(demoProduct1.id);
      expect(cart.totalItemCount, 0);
      expect(cart.isEmpty, isTrue);
    });
  });

  group('Catalog & Inventory Checks', () {
    test('Product stock status rules correctly identify Low Stock and Out of Stock', () {
      final inStockProduct = Product(
        id: 'T1',
        sku: 'T-1',
        name: 'In Stock Item',
        slug: 'in-stock',
        categoryId: 'CAT001',
        categoryName: 'Snacks',
        description: '',
        shortDescription: '',
        price: 50,
        compareAtPrice: 50,
        discountPercentage: 0,
        unit: 'pack',
        weight: '100g',
        stock: 25,
        lowStockThreshold: 10,
        image: '',
        images: [],
        isActive: true,
        isFeatured: false,
        isBestSeller: false,
        rating: 4.5,
        reviewCount: 10,
        tags: [],
        createdAt: '2026-09-30',
        updatedAt: '2026-09-30',
      );

      final lowStockProduct = inStockProduct.copyWith(stock: 5, lowStockThreshold: 10);
      final outOfStockProduct = inStockProduct.copyWith(stock: 0, lowStockThreshold: 10);

      expect(inStockProduct.stockStatus, 'IN STOCK');
      expect(inStockProduct.isLowStock, isFalse);
      expect(inStockProduct.isOutOfStock, isFalse);

      expect(lowStockProduct.stockStatus, 'LOW STOCK');
      expect(lowStockProduct.isLowStock, isTrue);
      expect(lowStockProduct.isOutOfStock, isFalse);

      expect(outOfStockProduct.stockStatus, 'OUT OF STOCK');
      expect(outOfStockProduct.isLowStock, isFalse);
      expect(outOfStockProduct.isOutOfStock, isTrue);
    });
  });
}
