import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toruerp/models/product.dart';
import 'package:toruerp/services/product_sercives.dart';
import 'package:toruerp/views/inventory/product/edit.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  _StockInScreenState createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
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

  Future<void> _reloadProducts() async {
    setState(() {
      currentPage = 1;
      hasMoreProducts = true;
      products.clear();
    });
    await _fetchProducts(); // Memanggil fungsi fetch untuk mengambil ulang data dari server
  }

  // Fungsi untuk mengambil produk dari API
  Future<void> _fetchProducts({String query = ""}) async {
    if (isLoadingMore || !hasMoreProducts) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      ProductSercives apiService = ProductSercives();
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

    _debounce = Timer(const Duration(milliseconds: 500), () {
      String searchText = _searchController.text;
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

  Future<void> _updateProduct(inStock, product) async {
    // Create updated product object

    try {
      ProductSercives productSercives = ProductSercives();

      productSercives.updateProduct(product.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')),
      );
    }
  }

  void showBottomDetail(product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 1.0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
            ),
            child: Column(
              children: [
                AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text('Detail Produk'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        product.images != null && product.images!.isNotEmpty
                            ? Image.network(
                                'https://pos.torufarm.com/storage/app/public/product/${product.images!.last}',
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.image_not_supported, size: 200),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                                'Stok Saat Ini : ${product.totalStock} /${product.unit}'),
                            //input tambah stok
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Jumlah Stok Ditambahkan',
                                    border: OutlineInputBorder(),
                                    suffixText: product.unit,
                                  ),
                                  onChanged: (value) {},
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void saveUpdateStock() {
    // Simpan perubahan stok produk
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            fillColor: Colors.amber,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: filteredProducts.isEmpty && !isLoadingMore
          ? const Center(child: Text("Tidak ada produk ditemukan"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        filteredProducts.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredProducts.length) {
                        return const SizedBox();
                      }

                      Product product = filteredProducts[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: ListTile(
                          leading: product.images != null &&
                                  product.images!.isNotEmpty
                              ? Image.network(
                                  'https://pos.torufarm.com/storage/app/public/product/${product.images!.last}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported);
                                  },
                                )
                              : Icon(Icons.image_not_supported),
                          title: Text(product.name),
                          subtitle: Text(
                              'Harga: Rp ${product.price}, Stok: ${product.totalStock} ${product.unit} ${product.categoryIds![0].id}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.add_shopping_cart,
                                    color: Colors.green),
                                onPressed: () {
                                  showBottomDetail(product);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}
