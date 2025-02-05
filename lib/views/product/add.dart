import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toruerp/models/category.dart';
import 'package:toruerp/models/product.dart';
import 'package:toruerp/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toruerp/models/category.dart';
import 'package:toruerp/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _hppController = TextEditingController();
  List<File> _selectedImages = [];
  List<ProductCategory> _categories = []; // Change to ProductCategory
  bool _isLoading = false;
  String? _selectedCategory; // Add selected category variable
  String? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _getCategories(); // Panggil untuk mendapatkan data kategori
  }

  Future<void> _getCategories() async {
    try {
      final response = await ApiService().getCategories();

      // Tambahkan kategori ke dalam list _categories
      setState(() {
        _categories = response.map((data) {
          return ProductCategory(
            id: data.id,
            name: data.name,
            parentId: data.parentId,
            position: data.position,
            status: data.status,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt,
            image: data.image,
            priority: data.priority,
            translations: data.translations,
          );
        }).toList();
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      _selectedImages =
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      List<String> base64Images = [];
      for (var imageFile in _selectedImages) {
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        base64Images.add(base64Image);
      }

      // Create categoryIds list based on the selected category
      List<CategoryIds> categoryIdsList = [];
      if (_selectedCategory != null) {
        categoryIdsList.add(CategoryIds(
          id: _selectedCategory,
          position: 1, // Set the appropriate position
        ));
      }

      Product newProduct = Product(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        totalStock: double.parse(_stockController.text),
        unit: _selectedUnit ?? '', // Add the selected unit
        images: base64Images,
        categoryIds: categoryIdsList, // Assign the categoryIds list
        hpp: double.parse(_hppController.text),
      );

      try {
        await ApiService().addProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil ditambah")),
        );
        Navigator.pop(context);
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan produk: $e")),
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
      appBar: AppBar(title: const Text("Tambah Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: _selectedImages.isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        children: _selectedImages.asMap().entries.map((entry) {
                          int index = entry.key;
                          File image = entry.value;
                          return Stack(
                            children: [
                              Image.file(
                                image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    : const Icon(Icons.image, size: 100),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _pickImageFromCamera,
                    child: const Text('Ambil Gambar'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text('Upload Gambar'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Produk"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama produk wajib diisi";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Harga"),
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
                decoration: const InputDecoration(labelText: "Stok"),
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
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(labelText: "Unit"),
                items: ['kg', 'pack', 'gram', 'dos']
                    .map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Unit wajib diisi";
                  }
                  return null;
                },
              ),
              // Dropdown untuk memilih kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Kategori"),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id.toString(), // Ganti dengan ID kategori
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kategori wajib dipilih";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hppController,
                decoration: const InputDecoration(labelText: "Hpp"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Hpp wajib diisi";
                  }
                  if (double.tryParse(value) == null) {
                    return "Hpp harus berupa angka";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitProduct,
                      child: const Text("Tambahkan Produk"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
