class Product {
  final String id;
  final String sku;
  final String name;
  final String slug;
  final String categoryId;
  final String categoryName;
  final String description;
  final String shortDescription;
  final double price;
  final double compareAtPrice;
  final double discountPercentage;
  final String currency;
  final String unit;
  final String weight;
  final int stock;
  final int lowStockThreshold;
  final String image;
  final List<String> images;
  final bool isActive;
  final bool isFeatured;
  final bool isBestSeller;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.slug,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.shortDescription,
    required this.price,
    required this.compareAtPrice,
    required this.discountPercentage,
    this.currency = 'INR',
    required this.unit,
    required this.weight,
    required this.stock,
    this.lowStockThreshold = 10,
    required this.image,
    this.images = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= lowStockThreshold;
  bool get isInStock => stock > lowStockThreshold;

  String get stockStatus {
    if (isOutOfStock) return 'OUT OF STOCK';
    if (isLowStock) return 'LOW STOCK';
    return 'IN STOCK';
  }

  double get savings => compareAtPrice > price ? (compareAtPrice - price) : 0.0;

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? slug,
    String? categoryId,
    String? categoryName,
    String? description,
    String? shortDescription,
    double? price,
    double? compareAtPrice,
    double? discountPercentage,
    String? currency,
    String? unit,
    String? weight,
    int? stock,
    int? lowStockThreshold,
    String? image,
    List<String>? images,
    bool? isActive,
    bool? isFeatured,
    bool? isBestSeller,
    double? rating,
    int? reviewCount,
    List<String>? tags,
    String? createdAt,
    String? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      currency: currency ?? this.currency,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      image: image ?? this.image,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      unit: json['unit'] as String? ?? 'pack',
      weight: json['weight'] as String? ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      image: json['image'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'slug': slug,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'shortDescription': shortDescription,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'discountPercentage': discountPercentage,
      'currency': currency,
      'unit': unit,
      'weight': weight,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'image': image,
      'images': images,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isBestSeller': isBestSeller,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
