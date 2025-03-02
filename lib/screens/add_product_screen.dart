import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ontrack/controller/product_controller.dart';
import 'package:ontrack/models/product_model.dart';
import 'package:ontrack/utils/image/img_pick.dart';
import 'package:http/http.dart' as http;

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<ProductScreen> {
  final ProductController _productService = ProductController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<String> _imageUrls = []; // Store image URLs here.
  Uint8List? _image;

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    String? photoUrl;
    if (_image != null) {
      String cloudName = "dagq3j3dp";
      String uploadPreset = "fwejxnfu";

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"),
      );

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        http.MultipartFile.fromBytes('file', _image!,
            filename: 'profile_image.png'),
      );

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var data = jsonDecode(responseData.body);
        photoUrl = data['secure_url'];
      } else {
        throw Exception("Image upload failed");
      }
    }

    if (name.isNotEmpty && _imageUrls.isNotEmpty) {
      final product =
          Product(name: name, photoUrl: photoUrl ?? '', price: price);
      await _productService.addProduct(product);
      _nameController.clear();
      _priceController.clear();
      _imageUrls.clear();
      setState(() {});
    }
  }

  // Example of adding image URL. In real app, you'd integrate with image picker/upload.
  void _addImageUrl(String url) {
    setState(() {
      _imageUrls.add(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number),
            ElevatedButton(onPressed: selectImage, child: Text("Select Image")),
            ElevatedButton(onPressed: _addProduct, child: Text('Add Product')),
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _productService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final products = snapshot.data!;
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle:
                              Text('\$${product.price.toStringAsFixed(2)}'),
                          leading: product.photoUrl.isNotEmpty
                              ? Image.network(product.photoUrl,
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : null,
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
