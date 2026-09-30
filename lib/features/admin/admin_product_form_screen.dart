import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/models/category_model.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../app/providers/catalog_provider.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _shortDescController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _comparePriceController;
  late TextEditingController _weightController;
  late TextEditingController _unitController;
  late TextEditingController _stockController;
  late TextEditingController _lowStockThresholdController;
  late TextEditingController _imageController;
  late TextEditingController _tagsController;

  String? _selectedCategoryId;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isBestSeller = false;
  bool _isSaving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _shortDescController = TextEditingController(text: p?.shortDescription ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? '${p.price.toInt()}' : '');
    _comparePriceController = TextEditingController(text: p != null ? '${p.compareAtPrice.toInt()}' : '');
    _weightController = TextEditingController(text: p?.weight ?? '100 g');
    _unitController = TextEditingController(text: p?.unit ?? 'pack');
    _stockController = TextEditingController(text: p != null ? '${p.stock}' : '50');
    _lowStockThresholdController = TextEditingController(text: p != null ? '${p.lowStockThreshold}' : '10');
    _imageController = TextEditingController(text: p?.image ?? 'assets/images/products/P001.png');
    _tagsController = TextEditingController(text: p?.tags.join(', ') ?? '');

    _selectedCategoryId = p?.categoryId ?? 'CAT001';
    _isActive = p?.isActive ?? true;
    _isFeatured = p?.isFeatured ?? false;
    _isBestSeller = p?.isBestSeller ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _weightController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    _imageController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final catalog = Provider.of<CatalogProvider>(context, listen: false);
      final categories = catalog.categories;
      Category? matchedCategory;
      for (final c in categories) {
        if (c.id == _selectedCategoryId) {
          matchedCategory = c;
          break;
        }
      }
      final category = matchedCategory ?? (categories.isNotEmpty ? categories.first : const Category(id: 'CAT001', name: 'Snacks', slug: 'snacks', description: '', image: ''));

      final price = double.parse(_priceController.text.trim());
      final comparePrice = _comparePriceController.text.trim().isNotEmpty
          ? double.parse(_comparePriceController.text.trim())
          : price;
      final discountPct = comparePrice > price
          ? (((comparePrice - price) / comparePrice) * 100).roundToDouble()
          : 0.0;

      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim().toLowerCase())
          .where((t) => t.isNotEmpty)
          .toList();

      final now = DateTime.now().toIso8601String().split('T')[0];

      final product = Product(
        id: widget.product?.id ?? 'P${(catalog.products.length + 1).toString().padLeft(3, '0')}',
        sku: _skuController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        slug: _nameController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
        categoryId: category.id,
        categoryName: category.name,
        description: _descController.text.trim(),
        shortDescription: _shortDescController.text.trim(),
        price: price,
        compareAtPrice: comparePrice,
        discountPercentage: discountPct,
        unit: _unitController.text.trim(),
        weight: _weightController.text.trim(),
        stock: int.parse(_stockController.text.trim()),
        lowStockThreshold: int.parse(_lowStockThresholdController.text.trim()),
        image: _imageController.text.trim(),
        images: [_imageController.text.trim()],
        isActive: _isActive,
        isFeatured: _isFeatured,
        isBestSeller: _isBestSeller,
        rating: widget.product?.rating ?? 4.5,
        reviewCount: widget.product?.reviewCount ?? 0,
        tags: tags,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      if (isEditing) {
        await catalog.updateProduct(product);
      } else {
        await catalog.addProduct(product);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Product updated successfully!' : 'New product created!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
            backgroundColor: Colors.white,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Section
                      _buildSectionCard(
                        title: 'Basic Information',
                        children: [
                          AppTextField(
                            controller: _nameController,
                            label: 'Product Name',
                            hint: 'e.g. Masala Potato Chips',
                            validator: (v) => Validators.requiredField(v, 'Product Name'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _skuController,
                                  label: 'SKU Code',
                                  hint: 'e.g. SNK-001',
                                  validator: (v) => Validators.requiredField(v, 'SKU'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Category',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedCategoryId,
                                      items: [
                                        for (final c in catalog.categories)
                                          DropdownMenuItem<String>(
                                            value: c.id,
                                            child: Text(c.name, style: const TextStyle(fontSize: 13)),
                                          ),
                                      ],
                                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _shortDescController,
                            label: 'Short Description',
                            hint: 'Brief 1-line product summary',
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _descController,
                            label: 'Detailed Description',
                            hint: 'Full ingredients, taste, and description',
                            maxLines: 3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pricing & Unit Section
                      _buildSectionCard(
                        title: 'Pricing & Specifications',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _priceController,
                                  label: 'Selling Price (₹)',
                                  hint: 'e.g. 30',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => Validators.positiveNumber(v, 'Price'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _comparePriceController,
                                  label: 'Compare Price / MRP (₹)',
                                  hint: 'e.g. 35',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _weightController,
                                  label: 'Weight / Volume',
                                  hint: 'e.g. 52 g or 300 ml',
                                  validator: (v) => Validators.requiredField(v, 'Weight'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _unitController,
                                  label: 'Unit Type',
                                  hint: 'e.g. pack, can, bottle',
                                  validator: (v) => Validators.requiredField(v, 'Unit'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Inventory Section
                      _buildSectionCard(
                        title: 'Inventory & Stock Level',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _stockController,
                                  label: 'Available Stock',
                                  hint: 'e.g. 100',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => Validators.positiveInteger(v, 'Stock'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _lowStockThresholdController,
                                  label: 'Low Stock Threshold',
                                  hint: 'e.g. 10',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => Validators.positiveInteger(v, 'Threshold'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _tagsController,
                            label: 'Tags (comma-separated)',
                            hint: 'chips, snacks, bestseller',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Switches Section
                      _buildSectionCard(
                        title: 'Visibility & Badges',
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            subtitle: const Text('Visible to customers in the catalog', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            value: _isActive,
                            activeThumbColor: AppColors.success,
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Featured Product', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            subtitle: const Text('Display in Popular Picks on Home screen', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            value: _isFeatured,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setState(() => _isFeatured = val),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Best Seller', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            subtitle: const Text('Show Best Seller badge and section', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            value: _isBestSeller,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setState(() => _isBestSeller = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                text: isEditing ? 'Update Product' : 'Save & Publish Product',
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
