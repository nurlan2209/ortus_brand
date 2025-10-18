class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final List<String> images;
  final List<SizeStock> sizes;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.images,
    required this.sizes,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: json['price'].toDouble(),
      images: List<String>.from(json['images'] ?? []),
      sizes: (json['sizes'] as List).map((s) => SizeStock.fromJson(s)).toList(),
      isActive: json['isActive'] ?? true,
    );
  }
}

class SizeStock {
  final String size;
  final int stock;

  SizeStock({required this.size, required this.stock});

  factory SizeStock.fromJson(Map<String, dynamic> json) {
    return SizeStock(size: json['size'], stock: json['stock']);
  }

  Map<String, dynamic> toJson() {
    return {'size': size, 'stock': stock};
  }
}
