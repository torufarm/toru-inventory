import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _hppController = TextEditingController();

  bool _isLoading = false;
  String? _selectedCategory;

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Object Add Product
      Product newProduct = Product(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        totalStock: double.parse(_stockController.text),
        unit: _unitController.text,
        hpp: double.parse(_hppController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await ApiService().addProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil ditambah')),
        );
        Navigator.pop(context);
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan produk $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nama Produk"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama produk wajib diisi";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Harga wajib diisi";
                  }
                  if (double.tryParse(value) == null) {
                    return "Harga harus berupa angka";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Stok wajib diisi";
                  }
                  if (double.tryParse(value) == null) {
                    return "Stok harus berupa angka";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(labelText: "Unit"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Unit wajib diisi";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hppController,
                decoration: InputDecoration(labelText: "Hpp"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Harga wajib diisi";
                  }
                  if (double.tryParse(value) == null) {
                    return "Harga harus berupa angka";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitProduct,
                      child: Text("Tambahkan Produk"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
