import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ontrack/common/style/heading.dart';
import 'package:ontrack/common/textfield/custom_textfield.dart';
import 'package:ontrack/controller/product_controller.dart';
import 'package:ontrack/models/product_model.dart';
import 'package:ontrack/screens/products/all_live_items_screen.dart';
import 'package:ontrack/screens/products/edit_product_screen.dart';
import 'package:ontrack/utils/image/img_pick.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';
import 'package:uuid/uuid.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<ProductScreen> {
  final ProductController _productController = ProductController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Uint8List? _selectedImage;
  bool isloading = false;

  Future<void> _selectImage() async {
    final image = await pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final uuid = Uuid();
    final productId = uuid.v4(); // Generates a unique ID
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    setState(() {
      isloading = true;
    });

    if (name.isEmpty) {
      _showSnackBar('Product name is required.', 'Error');
      return;
    }

    String? photoUrl;
    if (_selectedImage != null) {
      photoUrl = await _uploadImageToCloudinary(_selectedImage!);
      if (photoUrl == null) {
        _showSnackBar('Image upload failed.', 'Error');
        return;
      }
    }

    final product = Product(
        name: name, photoUrl: photoUrl ?? '', price: price, id: productId);
    await _productController.addProduct(product);

    _nameController.clear();
    _priceController.clear();
    setState(() => _selectedImage = null);
    setState(() {
      isloading = false;
    });

    _showSnackBar('Product added successfully.', 'Success');
  }

  Future<String?> _uploadImageToCloudinary(Uint8List image) async {
    const cloudName = "dagq3j3dp";
    const uploadPreset = "fwejxnfu";

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"),
    );

    request.fields['upload_preset'] = uploadPreset;
    request.files.add(
      http.MultipartFile.fromBytes('file', image,
          filename: 'product_image.png'),
    );

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData.body);
        return data['secure_url'];
      } else {
        return null;
      }
    } catch (e) {
      print("Cloudinary upload error: $e");
      return null;
    }
  }

  void _showSnackBar(
    String message,
    String title,
  ) {
    Get.snackbar(title, message);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
              title: const Text('Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                MyTextField(controller: _nameController, labelText: 'Name'),
                const SizedBox(height: 10),
                MyTextField(controller: _priceController, labelText: 'Price'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ThemeUtils.sameBrightness(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(_selectedImage!,
                                fit: BoxFit.cover))
                        : const Center(
                            child: Text('Tap to select image',
                                style: TextStyle(color: Colors.grey))),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: Text(
                        'Add Product',
                        style: TextStyle(
                            color: ThemeUtils.sameBrightness(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Heading(
                  title: 'Edit & Delete',
                  ontap: () {
                    Get.to(() => AllLiveItemsScreen());
                  },
                ),
                Expanded(
                  child: StreamBuilder<List<Product>>(
                    stream: _productController.getProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final products = snapshot.data!;
                        return ListView.builder(
                          itemCount: min(3, products.length),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: product.photoUrl.isNotEmpty
                                    ? Image.network(product.photoUrl,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover)
                                    : Container(
                                        height: 50,
                                        width: 50,
                                        color: Colors.grey[300],
                                        child:
                                            const Icon(Icons.image, size: 30),
                                      ),
                              ),
                              title: Text(
                                product.name,
                                style: TextStyle(
                                    color: ThemeUtils.dynamicTextColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit,
                                    color: AppColors.primaryColor),
                                onPressed: () {
                                  Get.to(() =>
                                      EditProductScreen(product: product));
                                },
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isloading)
          Container(
            color: Colors.black.withAlpha(200),
            child: Center(
                child: LoadingAnimationWidget.flickr(
              leftDotColor: AppColors.primaryColor,
              rightDotColor: Colors.white.withAlpha(200),
              size: 30.sp,
            )),
          ),
      ],
    );
  }
}
