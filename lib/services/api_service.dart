import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/product.dart';

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

  // Metode untuk mencari produk berdasarkan nama
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
        'total_stock': product.totalStock,
        'unit': product.unit,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  // Future<void> addProduct(Product product) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/products'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: json.encode(product.toJson()),
  //   );

  //   if (response.statusCode != 201) {
  //     throw Exception('Request failed with status: ${response.statusCode}.');
  //   }
  // }

  // Future<void> updateProduct(int id, Product product) async {
  //   final response = await http.put(
  //     Uri.parse('$baseUrl/products/$id'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: json.encode(product.toJson()),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Request failed with status: ${response.statusCode}.');
  //   }
  // }

  // Future<void> deleteProduct(int id) async {
  //   final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

  //   if (response.statusCode != 200) {
  //     throw Exception('Request failed with status: ${response.statusCode}.');
  //   }
  // }
}
