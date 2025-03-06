import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ontrack/controller/product_controller.dart';
import 'package:ontrack/models/product_model.dart';
import 'package:ontrack/screens/products/add_product_screen.dart';
import 'package:ontrack/screens/products/edit_product_screen.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class AllLiveItemsScreen extends ConsumerStatefulWidget {
  final String uid;
  const AllLiveItemsScreen({super.key, required this.uid});

  @override
  ConsumerState<AllLiveItemsScreen> createState() => _AllLiveItemsScreenState();
}

class _AllLiveItemsScreenState extends ConsumerState<AllLiveItemsScreen> {
  final ProductController _productController = ProductController();
  bool isProfUser = false; // If user exists, they're logged in
  @override
  void initState() {
    super.initState();
    isProfUser = FirebaseAuth.instance.currentUser!.uid == widget.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Live Items'),
        actions: [
          if (isProfUser)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Get.to(() => ProductScreen(
                      uid: widget.uid,
                    ));
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productController.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: product.photoUrl.isNotEmpty
                              ? Image.network(product.photoUrl,
                                  height: 50, width: 50, fit: BoxFit.cover)
                              : Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 30),
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
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit,
                              color: AppColors.primaryColor),
                          onPressed: () {
                            Get.to(() => EditProductScreen(product: product));
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
    );
  }
}
