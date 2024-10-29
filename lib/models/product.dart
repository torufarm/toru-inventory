class Product {
  final int? id;
  final List<String>? images;
  final String name;
  final String? description;
  List<CategoryIds>? categoryIds;
  final double price;
  final double? hpp;
  final double totalStock;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    this.images,
    required this.name,
    this.description,
    this.categoryIds,
    required this.price,
    this.hpp,
    required this.totalStock,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var imageList = <String>[];
    if (json['image'] != null) {
      imageList = List<String>.from(json['image']);
    }

    List<CategoryIds> categories = [];
    if (json['category_ids'] != null) {
      categories = (json['category_ids'] as List)
          .map((v) => CategoryIds.fromJson(v))
          .toList();
    }

    return Product(
      id: json['id'],
      name: json['name'],
      images: imageList,
      description: json['description'],
      categoryIds: categories,
      price: json['price'].toDouble(),
      hpp: json['hpp'] != null ? json['hpp'].toDouble() : null,
      totalStock: json['total_stock'].toDouble(),
      unit: json['unit'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': images,
      'description': description,
      'category_ids': categoryIds,
      'price': price,
      'hpp': hpp,
      'total_stock': totalStock,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CategoryIds {
  String? _id;

  CategoryIds({String? id}) {
    _id = id;
  }

  String? get id => _id;

  CategoryIds.fromJson(Map<String, dynamic> json) {
    _id = json['id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    return data;
  }
}

class ProductCategory {}
