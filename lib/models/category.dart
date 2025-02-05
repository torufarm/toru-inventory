class ProductCategory {
  final int id;
  final String name;
  final int parentId;
  final int position;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String image;
  final String priority;
  final List<dynamic> translations;

  ProductCategory({
    required this.id,
    required this.name,
    required this.parentId,
    required this.position,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.image,
    required this.priority,
    required this.translations,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
      parentId: json['parent_id'],
      position: json['position'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      image: json['image'],
      priority: json['priority'],
      translations: json['translations'],
    );
  }

  @override
  String toString() {
    return 'ProductCategory{id: $id, name: $name}'; // Menampilkan ID dan nama kategori
  }
}
