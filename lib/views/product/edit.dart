import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toruerp/models/product.dart';
import 'package:toruerp/services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _unitController;
  late TextEditingController _hppController;
  bool _isProductActive = false;
  List<File?> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _stockController =
        TextEditingController(text: widget.product.totalStock.toString());
    _unitController = TextEditingController(text: widget.product.unit);
    _hppController = TextEditingController(text: widget.product.hpp.toString());
    _isProductActive = widget.product.status == 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _hppController.dispose();
    super.dispose();

    // Initialize _isProductActive based on product status
  }

  Future<void> _pickImages() async {
    final pickedFiles =
        await ImagePicker().pickMultiImage(); // Menggunakan multi image picker
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

  void _changeStatusProduct(bool? status) {
    setState(() {
      _isProductActive = status ?? false;
    });
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      // Convert selected images to base64 strings
      List<String> base64Images = [];
      for (var imageFile in _selectedImages) {
        if (imageFile != null) {
          List<int> imageBytes = await imageFile.readAsBytes();
          String base64Image = base64Encode(imageBytes);
          base64Images.add(base64Image);
        }
      }

      // Create updated product object
      Product updatedProduct = Product(
        id: widget.product.id,
        images: base64Images,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        totalStock: double.parse(_stockController.text),
        status: _isProductActive ? 1 : 0,
        unit: _unitController.text,
        hpp: double.parse(_hppController.text),
        categoryIds: widget.product.categoryIds,
        createdAt: widget.product.createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        ApiService apiService = ApiService();
        await apiService.updateProduct(updatedProduct);

        Navigator.pop(context, updatedProduct);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui produk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
      ),
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
                          File? image = entry.value;
                          return Stack(
                            children: [
                              Image.file(
                                image!,
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
                    : widget.product.images != null &&
                            widget.product.images!.isNotEmpty
                        ? Image.network(
                            'https://pos.torufarm.com/storage/app/public/product/${widget.product.images![0]}',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
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
              CheckboxListTile(
                  title: const Text('Status'),
                  value: _isProductActive,
                  onChanged: _changeStatusProduct),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unit produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hppController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hpp'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unit produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProduct,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
