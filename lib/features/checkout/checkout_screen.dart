import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/order_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../app/providers/catalog_provider.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/providers/order_provider.dart';
import '../../app/providers/user_provider.dart';
import '../orders/order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _pincodeController;
  late TextEditingController _landmarkController;
  late TextEditingController _instructionsController;

  String _paymentMethod = 'COD'; // 'COD' or 'Online'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final defaultAddress = user?.defaultAddress;

    _nameController = TextEditingController(text: user?.name ?? 'Rahul Sharma');
    _phoneController = TextEditingController(text: user?.phone ?? '9876543210');
    _addressController = TextEditingController(text: defaultAddress?.line1 ?? 'Flat 402, Green Valley Apts');
    _cityController = TextEditingController(text: defaultAddress?.city ?? 'Jalandhar');
    _pincodeController = TextEditingController(text: defaultAddress?.pincode ?? '144001');
    _landmarkController = TextEditingController(text: 'Near City Mall');
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final catalog = Provider.of<CatalogProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser!;

      final address = OrderAddress(
        line1: '${_addressController.text.trim()}${_landmarkController.text.isNotEmpty ? ' (Landmark: ${_landmarkController.text.trim()})' : ''}',
        city: _cityController.text.trim(),
        state: 'Punjab',
        pincode: _pincodeController.text.trim(),
      );

      final newOrder = await orderProvider.placeOrder(
        user: user,
        address: address,
        cartItems: cart.itemList,
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        discount: cart.totalSavings,
        total: cart.total,
        paymentMethod: _paymentMethod,
        catalogProvider: catalog,
      );

      // Clear Cart
      cart.clearCart();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderConfirmationScreen(order: newOrder),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor: Colors.white,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Details Section
                  _buildCard(
                    title: 'Delivery Details',
                    icon: Icons.location_on_rounded,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          validator: (v) => Validators.requiredField(v, 'Name'),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter 10-digit mobile number',
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _addressController,
                          label: 'Address (House / Flat / Street)',
                          hint: 'Enter house no., building name, street',
                          maxLines: 2,
                          validator: (v) => Validators.requiredField(v, 'Address'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _cityController,
                                label: 'City',
                                hint: 'City',
                                validator: (v) => Validators.requiredField(v, 'City'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                controller: _pincodeController,
                                label: 'Pincode',
                                hint: '6-digit pincode',
                                keyboardType: TextInputType.number,
                                validator: Validators.pincode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _landmarkController,
                          label: 'Landmark (Optional)',
                          hint: 'e.g. Near City Hospital',
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _instructionsController,
                          label: 'Delivery Instructions (Optional)',
                          hint: 'e.g. Leave at door, don\'t ring bell',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Section
                  _buildCard(
                    title: 'Payment Method',
                    icon: Icons.payment_rounded,
                    child: Column(
                      children: [
                        _buildPaymentOption(
                          value: 'COD',
                          title: 'Cash on Delivery (COD)',
                          subtitle: 'Pay via cash or UPI when delivered',
                          icon: Icons.money_rounded,
                        ),
                        const Divider(height: 1),
                        _buildPaymentOption(
                          value: 'Online',
                          title: 'Mock Online Payment (Instant)',
                          subtitle: 'UPI, Credit/Debit Card, Netbanking',
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Summary Card
                  _buildCard(
                    title: 'Order Summary (${cart.totalItemCount} Items)',
                    icon: Icons.receipt_long_rounded,
                    child: Column(
                      children: [
                        ...cart.itemList.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '${item.quantity}x',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(item.totalPrice),
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text(CurrencyFormatter.format(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery Fee', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text(
                              cart.deliveryFee == 0 ? 'FREE' : CurrencyFormatter.format(cart.deliveryFee),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: cart.deliveryFee == 0 ? AppColors.success : AppColors.text,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            Text(CurrencyFormatter.format(cart.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomSheet: Container(
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
              child: CustomButton(
                text: 'Place Order • ${CurrencyFormatter.format(cart.total)}',
                isLoading: _isSubmitting,
                onPressed: _handlePlaceOrder,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == value;

    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.secondary : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: AppColors.secondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
