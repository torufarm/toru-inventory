import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toruerp/models/category.dart';
import 'package:toruerp/models/product.dart';

class ApiService {
  final String baseUrl = 'https://pos.torufarm.com';

  Future<List<Product>> fetchProducts(
      {int page = 1, int pageSize = 10, String searchQuery = ""}) async {
    String url = "$baseUrl/api/v1/products/all?page=$page&page_size=$pageSize";
    if (searchQuery.isNotEmpty) {
      url = "$baseUrl/api/v1/products/search?name=$searchQuery";
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> productsJson = jsonResponse['products'];

      return productsJson.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception("Gagal memuat produk");
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search?name=$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Product> products = (data['products'] as List)
          .map((product) => Product.fromJson(product))
          .toList();
      return products;
    } else {
      throw Exception('Failed to search products');
    }
  }

  Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/products/update/${product.id}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': product.name,
        'price': product.price,
        'status': product.status,
        'total_stock': product.totalStock,
        'unit': product.unit,
        'hpp': product.hpp,
        'images': product.images,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/products/add'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': product.name,
        'price': product.price,
        'total_stock': product.totalStock,
        'unit': product.unit,
        'category_ids': product.categoryIds,
        'status': product.status,
        'images': product.images,
      }),
    );

    print('Gambar ${response.body}');

    if (response.statusCode != 200) {
      throw Exception("Failed to add product ${response.body}");
      print(response.statusCode);
    }
  }

  Future<List<ProductCategory>> getCategories() async {
    String url = "$baseUrl/api/v1/categories";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      // Mengonversi setiap item dalam JSON menjadi ProductCategory
      return jsonResponse.map((data) {
        if (data is Map<String, dynamic>) {
          return ProductCategory.fromJson(data);
        } else {
          throw Exception('Data tidak sesuai: $data');
        }
      }).toList();
    } else {
      throw Exception(
          "Failed to load categories: ${response.statusCode} ${response.body}");
    }
  }
}
