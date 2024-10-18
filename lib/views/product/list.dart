import 'package:flutter/material.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/views/product/edit.dart';
import 'dart:async';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoadingMore = false;
  int currentPage = 1;
  final int pageSize = 10; 
  bool hasMoreProducts = true;
  String searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
    _fetchProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil produk dari API
  Future<void> _fetchProducts({String query = ""}) async {
    if (isLoadingMore || !hasMoreProducts) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      ApiService apiService = ApiService();
      // Jika ada query pencarian, maka gunakan searchQuery untuk pencarian
      List<Product> newProducts = await apiService.fetchProducts(
        page: currentPage,
        pageSize: pageSize,
        searchQuery: query.isNotEmpty
            ? query
            : searchQuery, // Jika ada pencarian, gunakan query
      );

      setState(() {
        if (currentPage == 1) {
          products = newProducts; // Ganti produk jika pencarian baru
        } else {
          products.addAll(newProducts); // Tambahkan produk untuk pagination
        }
        filteredProducts =
            products; // Inisialisasi filteredProducts dengan semua produk
        currentPage++;
        if (newProducts.length < pageSize) {
          hasMoreProducts = false; // Tidak ada lagi produk yang bisa dimuat
        }
      });
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  // Listener untuk pencarian
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () {
      String searchText = _searchController.text.trim().toLowerCase();
      setState(() {
        searchQuery = searchText; // Simpan query pencarian
        currentPage = 1; // Reset halaman
        products.clear(); // Hapus produk sebelumnya

        if (searchQuery.isEmpty) {
          // Jika pencarian kosong, ambil ulang semua produk
          hasMoreProducts = true; // Reset kondisi pagination
          _fetchProducts(); // Ambil produk tanpa filter pencarian
        } else {
          // Jika ada pencarian, ambil produk sesuai dengan query
          _fetchProducts(query: searchQuery);
        }
      });
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchProducts(); // Ambil lebih banyak produk saat scroll ke bawah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari produk...',
            border: InputBorder.none,
            fillColor: Colors.amber,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: filteredProducts.isEmpty && !isLoadingMore
          ? Center(child: Text("Tidak ada produk ditemukan"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        filteredProducts.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredProducts.length) {
                        return SizedBox();
                      }

                      Product product = filteredProducts[index];
                      return Card(
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                              'Harga: Rp ${product.price}, Stok: ${product.totalStock} ${product.unit}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final updatedProduct = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditProductScreen(product: product),
                                    ),
                                  );
                                  if (updatedProduct != null) {
                                    setState(() {
                                      int index = products.indexWhere(
                                          (p) => p.id == updatedProduct.id);
                                      if (index != -1) {
                                        products[index] =
                                            updatedProduct; // Update produk di daftar
                                      }
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Aksi Hapus
                                },
                              ),
                            ],
                          ),
                        ),
                        elevation: 2,
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      );
                    },
                  ),
                ),
                if (isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}
