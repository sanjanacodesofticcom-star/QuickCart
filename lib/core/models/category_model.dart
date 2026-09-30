class Category {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String image;
  final bool isActive;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.image,
    this.isActive = true,
    this.sortOrder = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? image,
    bool? isActive,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }
}
