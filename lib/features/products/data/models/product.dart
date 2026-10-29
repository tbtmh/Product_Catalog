class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
  });

  double get discountedPrice => price * (1 - discountPercentage / 100);

  bool get hasDiscount => discountPercentage > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String?,
      thumbnail: (json['thumbnail'] ?? '') as String,
      images: ((json['images'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class ProductPage {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    return ProductPage(
      products: ((json['products'] as List?) ?? const [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }
}
