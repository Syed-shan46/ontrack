import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ontrack/common/textfield/custom_textfield.dart';
import 'package:ontrack/models/product_model.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
  }

  Future<void> updateProduct(
      String productId, String newName, double newPrice) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final productRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .doc(productId);

      final docSnapshot = await productRef.get();
      if (!docSnapshot.exists) {
        print("❌ Firestore does NOT contain product with ID: $productId");
        throw Exception("Product not found!");
      }

      await productRef.update({
        'name': newName,
        'price': newPrice,
      });

      print("✅ Product updated successfully");
    } else {
      throw Exception("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MyTextField(
              controller: _nameController,
              labelText: "Product Name",
            ),
            const SizedBox(height: 10),
            MyTextField(
                labelText: "Price",
                controller: _priceController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print("Widget Product ID: ${widget.product.id}");
                try {
                  await updateProduct(widget.product.id, _nameController.text,
                      double.parse(_priceController.text));
                  Get.back();
                } catch (e) {
                  print("❌ Error updating product: $e");
                  Get.snackbar("Error", e.toString());
                }
              },
              child: const Text("Update Product"),
            ),
          ],
        ),
      ),
    );
  }
}
