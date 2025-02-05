import 'package:flutter/material.dart';

class Product {
  final int? id;
  final List<String>? images;
  final String name;
  final String? description;
  final int? status;
  List<CategoryIds>? categoryIds;
  final double price;
  final double? hpp;
  final double totalStock;
  final String unit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product(
      {this.id,
      this.images,
      required this.name,
      this.description,
      this.status,
      this.categoryIds,
      required this.price,
      this.hpp,
      required this.totalStock,
      required this.unit,
      this.createdAt,
      this.updatedAt});

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
      status: json['status'],
      description: json['description'],
      categoryIds: categories,
      price: json['price'].toDouble(),
      hpp: json['hpp']?.toDouble(),
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
      'status': status,
      'category_ids': categoryIds,
      'price': price,
      'hpp': hpp,
      'total_stock': totalStock,
      'unit': unit,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CategoryIds {
  String? id; // Changed from private to public for easier access
  int? position; // Added position field

  CategoryIds(
      {this.id, this.position}); // Constructor updated to initialize fields

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    position = json['position']; // Initialize position from JSON
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position, // Include position in JSON
    };
  }
}
